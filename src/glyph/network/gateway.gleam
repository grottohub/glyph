//// This handles the logic for communicating with the Discord Gateway API. For more information: https://discord.com/developers/docs/topics/gateway

import gleam/dynamic
import gleam/erlang/process
import gleam/float
import gleam/function
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/http/request
import gleam/int
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
  TimeUpdated(String)
}

pub type GatewayError {
  JsonError(json.DecodeError)
  DynError(dynamic.DecodeError)
  DynErrors(dynamic.DecodeErrors)
  TimeError
}

pub type ActorState {
  ActorState(seq: Option(Int), heartbeat_in_ms: Int, self: process.Subject(Msg))
}

fn jitter(heartbeat_interval: Float) -> Int {
  let gen_jitter: Generator(Float) = random.float(0.0, 1.0)
  { random.random_sample(gen_jitter) *. heartbeat_interval }
  |> float.truncate
}

fn fallback_event() -> discord.GatewayEvent {
  discord.GatewayEvent(op: -1, d: dynamic.from(""), s: None, t: None)
}

fn fallback_hello() -> discord.HelloEvent {
  discord.HelloEvent(heartbeat_interval: -1)
}

fn heartbeat_json(seq: Option(Int)) -> String {
  json.object([#("op", json.int(1)), #("d", json.nullable(seq, of: json.int))])
  |> json.to_string
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
    1 -> {
      logging.log(logging.Info, "Received Heartbeat request from gateway")

      let _heartbeat =
        stratus.send_text_message(conn, heartbeat_json(state.seq))

      Ok(state)
    }
    10 -> {
      logging.log(logging.Info, "Received Hello from gateway")
      let hello =
        decoders.gateway_hello_decoder(event.d)
        |> result.unwrap(or: fallback_hello())

      let jit = jitter(int.to_float(hello.heartbeat_interval))
      logging.log(
        logging.Debug,
        "Sleeping for " <> int.to_string(jit) <> " before sending heartbeat",
      )
      process.send_after(state.self, jit, Heartbeat)

      Ok(ActorState(..state, heartbeat_in_ms: hello.heartbeat_interval))
    }
    11 -> {
      logging.log(logging.Info, "Received Heartbeat ACK from gateway")

      Ok(state)
    }
    -1 -> {
      logging.log(logging.Warning, "Reached fallback event")
      Ok(state)
    }
    _ -> {
      logging.log(logging.Warning, "Received unexpected op code")
      Ok(state)
    }
  }
}

pub fn start_ws_loop(url: String) {
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
        #(ActorState(seq: None, heartbeat_in_ms: 0, self: subj), Some(selector))
      },
      loop: fn(msg, state, conn) {
        logging.log(logging.Debug, state_to_string(state))

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
