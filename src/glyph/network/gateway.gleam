//// This handles the logic for communicating with the Discord Gateway API. For more information: https://discord.com/developers/docs/topics/gateway

import gleam/dynamic
import gleam/erlang/process
import gleam/float
import gleam/function
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/http/request
import gleam/int
import gleam/io
import gleam/otp/actor
import gleam/result
import glyph/network/rest
import glyph/models/decoders
import glyph/models/discord
import stratus
import logging
import prng/random.{type Generator}

pub type Msg {
  Close
  Heartbeat
  Identify
  Resume
  TimeUpdated(String)
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
    identified: Bool,
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

pub fn handle_gateway_recv(
  msg: String,
  state: ActorState,
  conn: stratus.Connection,
) -> Result(ActorState, GatewayError) {
  let event =
    json.decode(from: msg, using: decoders.gateway_event_decoder())
    |> result.unwrap(or: fallback_event())

  case event.op {
    0 -> {
      logging.log(logging.Info, "Received Ready event from gateway")
      let ready = decoders.gateway_ready_decoder(event.d)

      case ready {
        Ok(ev) -> {
          io.debug(ev)
          Ok(ActorState(..state, identified: True))
        }
        Error(e) -> {
          logging.log(logging.Error, "Error parsing Ready event")
          io.debug(e)
          Ok(state)
        }
      }
    }
    1 -> {
      logging.log(logging.Info, "Received Heartbeat request from gateway")

      let _heartbeat =
        stratus.send_text_message(conn, heartbeat_json(state.seq))

      Ok(state)
    }
    9 -> {
      logging.log(logging.Warning, "Received Invalid Session from gateway")

      Ok(state)
    }
    10 -> {
      logging.log(logging.Info, "Received Hello from gateway")
      let hello =
        decoders.gateway_hello_decoder(event.d)
        |> result.unwrap(or: fallback_hello())

      let jit = jitter(int.to_float(hello.heartbeat_interval))
      logging.log(logging.Debug, "Jitter value: " <> int.to_string(jit))
      process.send_after(state.self, jit, Heartbeat)

      Ok(ActorState(..state, heartbeat_in_ms: hello.heartbeat_interval))
    }
    11 -> {
      logging.log(logging.Info, "Received Heartbeat ACK from gateway")

      case state.identified {
        True -> Ok(state)
        False -> {
          logging.log(logging.Warning, "Not currently identified")
          process.send(state.self, Identify)
          Ok(state)
        }
      }
    }
    -1 -> {
      logging.log(logging.Warning, "Reached fallback event")
      Ok(state)
    }
    n -> {
      logging.log(
        logging.Warning,
        "Received unexpected op code " <> int.to_string(n),
      )
      Ok(state)
    }
  }
}

pub fn start_ws_loop(discord_token: String, url: String) {
  let assert Ok(req) =
    request.to(url <> "/?v=" <> rest.api_version <> "&encoding=json")

  let builder =
    stratus.websocket(
      request: req,
      init: fn() {
        let subj = process.new_subject()
        let selector =
          process.new_selector()
          |> process.selecting(subj, function.identity)
        #(
          ActorState(
            seq: None,
            heartbeat_in_ms: 0,
            self: subj,
            identified: False,
          ),
          Some(selector),
        )
      },
      loop: fn(msg, state, conn) {
        // logging.log(logging.Debug, state_to_string(state))

        case msg {
          stratus.Text(msg) -> {
            logging.log(logging.Debug, "RECV: " <> msg)
            let new_state = handle_gateway_recv(msg, state, conn)
            case new_state {
              Ok(n) -> actor.continue(n)
              Error(_) -> {
                logging.log(
                  logging.Error,
                  "Encountered error when processing message",
                )
                actor.continue(state)
              }
            }
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
            logging.log(logging.Debug, identify_json(discord_token, "linux"))
            let _identify =
              stratus.send_text_message(
                conn,
                identify_json(discord_token, "linux"),
              )
            actor.continue(state)
          }
          stratus.User(Close) -> {
            logging.log(logging.Info, "Closing WebSocket connection")
            let assert Ok(_) = stratus.close(conn)
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

  let assert Ok(subj) = stratus.initialize(builder)

  process.start(
    fn() {
      process.sleep(120_000)
      stratus.send_message(subj, Close)
    },
    True,
  )

  let _done =
    process.new_selector()
    |> process.selecting_process_down(
      process.monitor_process(process.subject_owner(subj)),
      function.identity,
    )
    |> process.select_forever

  logging.log(logging.Debug, "WebSocket process exited")
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

fn identify_json(token: String, os: String) -> String {
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
        #("intents", json.int(7)),
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
