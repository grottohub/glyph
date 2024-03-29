//// This handles the logic for communicating with the Discord Gateway API. For more information: https://discord.com/developers/docs/topics/gateway

import gleam/dynamic
import gleam/erlang/process
import gleam/float
import gleam/function
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/http/request
import gleam/io.{debug}
import gleam/int
import gleam/otp/actor
import gleam/result
import gleam/string
import glyph/internal/network/rest
import glyph/internal/decoders
import glyph/models/discord
import stratus
import logging
import prng/random.{type Generator}

pub type Msg {
  Close
  Heartbeat
  Identify
  Resume
}

pub type GatewayError {
  JsonError(json.DecodeError)
  DynError(dynamic.DecodeError)
  DynErrors(dynamic.DecodeErrors)
}

pub type ActorState {
  ActorState(
    seq: Option(Int),
    heartbeat_in_ms: Int,
    self: process.Subject(Msg),
    resume_gateway_url: String,
    bot_id: discord.Snowflake,
    handlers: discord.EventHandler,
    received_hello: Bool,
  )
}

fn state_to_string(state: ActorState) -> String {
  let seq =
    state.seq
    |> option.unwrap(or: -1)
    |> int.to_string

  let interval =
    state.heartbeat_in_ms
    |> int.to_string

  "STATE: seq: " <> seq <> " heartbeat_in_ms: " <> interval
}

/// This handles communicating with the gateway based on op codes: https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
fn handle_gateway_recv(
  msg: String,
  state: ActorState,
  conn: stratus.Connection,
  bot_subj: process.Subject(rest.RESTMessage),
) -> ActorState {
  let event =
    json.decode(from: msg, using: decoders.gateway_event_decoder())
    |> result.unwrap(or: fallback_event())

  case event.op {
    // 0 is Dispatch, so most users of this library will want events that will come through this branch
    0 -> {
      logging.log(logging.Debug, "Received Dispatch event from gateway")

      let event_type = option.unwrap(event.t, or: "")

      case event_type {
        "READY" -> {
          let ready = decoders.gateway_ready_decoder(event.d)

          case ready {
            Ok(ev) -> {
              let resume_url =
                string.replace(ev.resume_gateway_url, "wss", "https")
              ActorState(
                ..state,
                bot_id: ev.user.id,
                resume_gateway_url: resume_url
                <> "/?v="
                <> rest.api_version
                <> "&encoding=json",
              )
            }
            Error(_) -> {
              logging.log(logging.Error, "Error parsing Ready event")
              state
            }
          }
        }
        "MESSAGE_CREATE" -> {
          logging.log(logging.Debug, "Handling MESSAGE_CREATE event")
          let message = decoders.message_decoder(event.d)


          debug(event)
          debug(message)
        

          case message {
            Ok(msg) -> {
              case msg.author.id == state.bot_id {
                True -> {
                  logging.log(logging.Debug, "I think that I am the author")
                  state
                }
                False -> {
                  logging.log(logging.Debug, "Invoking on_message_create")
                  let _ = state.handlers.on_message_create(bot_subj, msg)
                  state
                }
              }
            }
            Error(_) -> {
              logging.log(logging.Error, "Error parsing MESSAGE_CREATE event")
              state
            }
          }

          state
        }
        "" -> {
          logging.log(logging.Warning, "Received Dispatch event with no type")
          state
        }
        u -> {
          logging.log(
            logging.Warning,
            "Received Dispatch event with unsupported type: " <> u,
          )
          state
        }
      }
    }
    1 -> {
      logging.log(logging.Debug, "Received Heartbeat request from gateway")

      let _heartbeat =
        stratus.send_text_message(conn, heartbeat_json(state.seq))

      state
    }
    9 -> {
      logging.log(logging.Warning, "Received Invalid Session from gateway")

      state
    }
    10 -> {
      case state.received_hello {
        False -> {
          logging.log(logging.Debug, "Received Hello from gateway")
          let hello =
            decoders.gateway_hello_decoder(event.d)
            |> result.unwrap(or: fallback_hello())

          let jit = jitter(int.to_float(hello.heartbeat_interval))
          logging.log(logging.Debug, "Jitter value: " <> int.to_string(jit))
          process.send_after(state.self, jit, Heartbeat)
          process.send(state.self, Identify)

          ActorState(
            ..state,
            heartbeat_in_ms: hello.heartbeat_interval,
            received_hello: True,
          )
        }
        True -> state
      }
    }
    11 -> {
      logging.log(logging.Debug, "Received Heartbeat ACK from gateway")

      state
    }
    -1 -> {
      logging.log(
        logging.Warning,
        "Reached fallback event with " <> state_to_string(state),
      )
      state
    }
    // The following range of op codes are reasons the gateway closed the connection: https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
    4008 -> {
      logging.log(
        logging.Error,
        "You have been rate limited for sending too many requests.",
      )
      process.send(state.self, Close)
      state
    }
    4013 -> {
      logging.log(
        logging.Error,
        "You sent an invalid intent for a Gateway Intent. You may have incorrectly calculated the bitwise value.",
      )
      process.send(state.self, Close)
      state
    }
    4014 -> {
      logging.log(
        logging.Error,
        "You sent a disallowed intent for a Gateway Intent. You may have tried to specify an intent that you have not enabled or are not approved for.",
      )
      process.send(state.self, Close)
      state
    }
    n -> {
      logging.log(
        logging.Warning,
        "Received unexpected op code " <> int.to_string(n),
      )
      state
    }
  }
}

pub fn start_gateway_actor(
  supervisor_subj: process.Subject(process.Subject(Msg)),
  bot_subj: process.Subject(rest.RESTMessage),
  discord_token: String,
  intents: Int,
  url: String,
  event_handlers: discord.EventHandler,
) -> Result(process.Subject(stratus.InternalMessage(Msg)), actor.StartError) {
  let confirm_https_url = string.replace(url, "wss", "https")
  let assert Ok(req) =
    request.to(
      confirm_https_url <> "/?v=" <> rest.api_version <> "&encoding=json",
    )

  let builder =
    stratus.websocket(
      request: req,
      init: fn() {
        let actor_subj = process.new_subject()
        process.send(supervisor_subj, actor_subj)
        let selector =
          process.new_selector()
          |> process.selecting(actor_subj, function.identity)
        #(
          ActorState(
            seq: None,
            heartbeat_in_ms: 0,
            self: actor_subj,
            resume_gateway_url: "",
            bot_id: "",
            handlers: event_handlers,
            received_hello: False,
          ),
          Some(selector),
        )
      },
      loop: fn(msg, state, conn) {
        case msg {
          stratus.Text(msg) -> {
            logging.log(logging.Debug, "RECV: " <> msg)
            let new_state = handle_gateway_recv(msg, state, conn, bot_subj)
            actor.continue(new_state)
          }
          stratus.User(Heartbeat) -> {
            logging.log(logging.Debug, "Sending heartbeat")
            let _heartbeat =
              stratus.send_text_message(conn, heartbeat_json(state.seq))
            process.send_after(state.self, state.heartbeat_in_ms, Heartbeat)
            actor.continue(state)
          }
          stratus.User(Identify) -> {
            logging.log(logging.Debug, "Sending Identify")
            let _identify =
              stratus.send_text_message(
                conn,
                identify_json(discord_token, intents, "linux"),
              )
            actor.continue(state)
          }
          stratus.User(Close) -> {
            logging.log(logging.Info, "Closing WebSocket connection")
            case stratus.close(conn) {
              Ok(_) -> Nil
              Error(e) -> {
                logging.log(
                  logging.Error,
                  "Error closing websocket: " <> string.inspect(e),
                )
              }
            }
            actor.Stop(process.Normal)
          }
          _ -> {
            logging.log(logging.Warning, "Reached unexpected case")
            actor.continue(state)
          }
        }
      },
    )
    |> stratus.on_close(fn(_state) {
      logging.log(logging.Debug, "WebSocket process closing")
    })

  stratus.initialize(builder)
}

// Functions for default / fallback objects

fn fallback_event() -> discord.GatewayEvent {
  discord.GatewayEvent(op: -1, d: dynamic.from(""), s: None, t: None)
}

fn fallback_hello() -> discord.HelloEvent {
  discord.HelloEvent(heartbeat_interval: -1)
}

// JSON payloads to send to the gateway

fn heartbeat_json(seq: Option(Int)) -> String {
  json.object([#("op", json.int(1)), #("d", json.nullable(seq, of: json.int))])
  |> json.to_string
}

fn identify_json(token: String, intents: Int, os: String) -> String {
  let properties =
    json.object([
      #("os", json.string(os)),
      #("browser", json.string("glyph")),
      #("device", json.string("glyph")),
    ])
  json.object([
    #("op", json.int(2)),
    #(
      "d",
      json.object([
        #("intents", json.int(intents)),
        #("token", json.string(token)),
        #("properties", properties),
      ]),
    ),
  ])
  |> json.to_string
}

// Misc helpers

fn jitter(heartbeat_interval: Float) -> Int {
  let gen_jitter: Generator(Float) = random.float(0.0, 1.0)
  { random.random_sample(gen_jitter) *. heartbeat_interval }
  |> float.truncate
}
