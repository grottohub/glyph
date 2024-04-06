//// This handles the logic for communicating with the Discord Gateway API. For more information: https://discord.com/developers/docs/topics/gateway

import gleam/dynamic
import gleam/erlang/process
import gleam/float
import gleam/function
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/http/request
import gleam/io.{debug}
import gleam/int
import gleam/otp/actor
import gleam/result
import gleam/string
import glyph/internal/cache
import glyph/internal/network/rest
import glyph/internal/decoders
import glyph/models/discord
import stratus
import logging
import prng/random.{type Generator}
import carpenter/table

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
  ActorError(actor.StartError)
  InvalidSessionError
}

pub type ActorState {
  ActorState(
    self: process.Subject(Msg),
    bot_id: discord.Snowflake,
    handlers: discord.EventHandler,
    session_cache: table.Set(String, String),
    received_hello: Bool,
    heartbeat_in_ms: Int,
    seq: Option(Int),
    invalid: Bool,
  )
}

/// This handles communicating with the gateway based on op codes: https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
fn handle_gateway_recv(
  msg: String,
  state: ActorState,
  conn: stratus.Connection,
  bot: discord.BotClient,
) -> ActorState {
  let event =
    json.decode(from: msg, using: decoders.decode_gateway_event)
    |> result.unwrap(or: fallback_event())

  case event.op {
    // 0 is Dispatch, so most users of this library will want events that will come through this branch
    0 -> {
      logging.log(logging.Debug, "Received Dispatch event from gateway")

      let event_type = option.unwrap(event.t, or: "")

      case event_type {
        "READY" -> {
          let ready = decoders.decode_ready_event(event.d)

          case ready {
            Ok(ev) -> {
              state.session_cache
              |> table.insert("resume_gateway_url", ev.resume_gateway_url)
              ActorState(..state, bot_id: ev.user.id)
            }
            Error(_) -> {
              logging.log(logging.Error, "Error parsing Ready event")
              state
            }
          }
        }
        "MESSAGE_CREATE" -> {
          logging.log(logging.Debug, "Handling MESSAGE_CREATE event")
          let message = decoders.decode_message(event.d)

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
                  let _ = state.handlers.on_message_create(bot, msg)
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
    7 -> {
      logging.log(logging.Debug, "Received Reconnect request from gateway")

      state.session_cache
      |> table.insert("should_resume", "true")

      process.send(state.self, Close)
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
            decoders.decode_hello_event(event.d)
            |> result.unwrap(or: fallback_hello())

          let jit = jitter(int.to_float(hello.heartbeat_interval))
          logging.log(logging.Debug, "Jitter value: " <> int.to_string(jit))
          process.send_after(state.self, jit, Heartbeat)
          let should_resume = cache.should_resume(state.session_cache, False)

          case should_resume {
            True -> process.send(state.self, Resume)
            False -> process.send(state.self, Identify)
          }

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
    // The following range of op codes are reasons the gateway closed the connection: https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
    4000 -> {
      logging.log(
        logging.Error,
        "An unknown error occurred. Attempting reconnect.",
      )
      table.insert(state.session_cache, "should_resume", "true")
      process.send(state.self, Close)
      state
    }
    4001 -> {
      logging.log(
        logging.Error,
        "You sent an invalid opcode or an invalid payload for an opcode.",
      )
      table.insert(state.session_cache, "should_resume", "true")
      process.send(state.self, Close)
      state
    }
    4002 -> {
      logging.log(logging.Error, "You sent an invalid payload.")
      table.insert(state.session_cache, "should_resume", "true")
      process.send(state.self, Close)
      state
    }
    4003 -> {
      logging.log(logging.Error, "You sent a payload prior to identifying.")
      table.insert(state.session_cache, "should_resume", "false")
      process.send(state.self, Close)
      state
    }
    4004 -> {
      logging.log(
        logging.Error,
        "The account token sent with your identify payload is incorrect.",
      )
      table.insert(state.session_cache, "should_resume", "false")
      table.insert(state.session_cache, "invalid_session", "true")
      process.send(state.self, Close)
      state
    }
    4005 -> {
      logging.log(logging.Error, "You send more than one identify payload.")
      table.insert(state.session_cache, "should_resume", "true")
      process.send(state.self, Close)
      state
    }
    4007 -> {
      logging.log(
        logging.Error,
        "Invalid sequence sent when resuming the session.",
      )
      table.insert(state.session_cache, "should_resume", "false")
      process.send(state.self, Close)
      state
    }
    4008 -> {
      logging.log(
        logging.Error,
        "You have been rate limited for sending too many requests.",
      )
      table.insert(state.session_cache, "should_resume", "true")
      process.send(state.self, Close)
      state
    }
    4009 -> {
      logging.log(logging.Error, "Session timed out.")
      table.insert(state.session_cache, "should_resume", "false")
      process.send(state.self, Close)
      state
    }
    4010 -> {
      logging.log(logging.Error, "You sent an invalid shard when identifying.")
      table.insert(state.session_cache, "should_resume", "false")
      table.insert(state.session_cache, "invalid_session", "true")
      process.send(state.self, Close)
      state
    }
    4011 -> {
      logging.log(
        logging.Error,
        "The session would have handled too many guilds - shard your connection to connect.",
      )
      table.insert(state.session_cache, "should_resume", "false")
      table.insert(state.session_cache, "invalid_session", "true")
      process.send(state.self, Close)
      state
    }
    4012 -> {
      logging.log(logging.Error, "You sent an invalid version for the gateway.")
      table.insert(state.session_cache, "should_resume", "false")
      table.insert(state.session_cache, "invalid_session", "true")
      process.send(state.self, Close)
      state
    }
    4013 -> {
      logging.log(
        logging.Error,
        "You sent an invalid intent for a Gateway Intent. You may have incorrectly calculated the bitwise value.",
      )
      table.insert(state.session_cache, "should_resume", "false")
      table.insert(state.session_cache, "invalid_session", "true")
      process.send(state.self, Close)
      state
    }
    4014 -> {
      logging.log(
        logging.Error,
        "You sent a disallowed intent for a Gateway Intent. You may have tried to specify an intent that you have not enabled or are not approved for.",
      )
      table.insert(state.session_cache, "should_resume", "false")
      table.insert(state.session_cache, "invalid_session", "true")
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
  bot: discord.BotClient,
  url: String,
  session_cache: table.Set(String, String),
) -> Result(process.Subject(stratus.InternalMessage(Msg)), actor.StartError) {
  let init_req = determine_url(session_cache, url)
  let builder =
    stratus.websocket(
      request: init_req,
      init: fn() {
        let actor_subj = process.new_subject()
        process.send(supervisor_subj, actor_subj)
        let selector =
          process.new_selector()
          |> process.selecting(actor_subj, function.identity)
        #(
          ActorState(
            self: actor_subj,
            bot_id: "",
            handlers: bot.handlers,
            session_cache: session_cache,
            received_hello: False,
            heartbeat_in_ms: 0,
            seq: None,
            invalid: cache.invalid_session(session_cache, False),
          ),
          Some(selector),
        )
      },
      loop: fn(msg, state, conn) {
        case msg, state.invalid {
          _, True -> {
            logging.log(logging.Error, "Invalid session, refusing to connect.")
            actor.continue(state)
          }
          stratus.Text(msg), _ -> {
            logging.log(logging.Debug, "RECV: " <> msg)
            let new_state = handle_gateway_recv(msg, state, conn, bot)
            actor.continue(new_state)
          }
          stratus.User(Heartbeat), _ -> {
            logging.log(logging.Debug, "Sending heartbeat")
            let _heartbeat =
              stratus.send_text_message(conn, heartbeat_json(state.seq))
            process.send_after(state.self, state.heartbeat_in_ms, Heartbeat)
            actor.continue(state)
          }
          stratus.User(Identify), _ -> {
            logging.log(logging.Debug, "Sending Identify")
            let _identify =
              stratus.send_text_message(
                conn,
                identify_json(bot.token, bot.intents, "linux"),
              )
            actor.continue(state)
          }
          stratus.User(Resume), _ -> {
            logging.log(logging.Debug, "Attempting to resume session")
            let seq = cache.seq(state.session_cache, 0)
            let session_id = cache.session_id(state.session_cache, "")
            let _resume =
              stratus.send_text_message(
                conn,
                resume_json(bot.token, session_id, seq),
              )
            table.insert(state.session_cache, "should_resume", "false")
            actor.continue(state)
          }
          stratus.User(Close), _ -> {
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
          _, _ -> {
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

fn resume_json(token: String, session_id: String, seq: Int) -> String {
  json.object([
    #("op", json.int(6)),
    #(
      "d",
      json.object([
        #("token", json.string(token)),
        #("session_id", json.string(session_id)),
        #("seq", json.int(seq)),
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

fn determine_url(
  session_cache: table.Set(String, String),
  url: String,
) -> request.Request(String) {
  let resume_url = cache.resume_gateway_url(session_cache, url)
  let should_resume = cache.should_resume(session_cache, False)

  let base_url = case should_resume {
    True -> string.replace(resume_url, "wss", "https")
    False -> string.replace(url, "wss", "https")
  }

  let assert Ok(init_req) =
    request.to(base_url <> "/?v=" <> rest.api_version <> "&encoding=json")

  init_req
}
