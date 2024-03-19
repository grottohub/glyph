//// This handles the logic for communicating with the Discord Gateway API. For more information: https://discord.com/developers/docs/topics/gateway

import gleam/dynamic
import gleam/erlang/process
import gleam/function
import gleam/json
import gleam/option.{type Option, None}
import gleam/http/request
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
  TimeUpdated(String)
}

pub type ActorState {
  ActorState(seq: Option(Int))
}

fn jitter(heartbeat_interval: Float) -> Float {
  let gen_jitter: Generator(Float) = random.float(0.0, 1.0)
  random.random_sample(gen_jitter) *. heartbeat_interval
}

// pub fn extract_float(decoded: Parent) -> Float {
//   dynamic.field("some_field", dynamic.int)(decoded.nested_field)
//   |> result.unwrap(or: 0)
//   |> int.to_float
// }

pub fn handle_gateway_event(
  event_string,
) -> Result(discord.GatewayEvent, json.DecodeError) {
  use event <- result.try(json.decode(
    from: event_string,
    using: decoders.gateway_event_decoder(),
  ))

  // use number <- result.try(dynamic.element(0, dynamic.int)(data))

  case event.op {
    10 -> {
      logging.log(logging.Info, "Received Hello from gateway")
      use hello_data <- result.try(
        dynamic.any(of: [decoders.hello_event_decoder()]),
      )
      Ok(event)
    }
    11 -> {
      logging.log(logging.Info, "Received Heartbeat ACK from gateway")
      Ok(event)
    }
    _ -> Ok(event)
  }
}

pub fn start_ws_loop(url: String) {
  let assert Ok(req) =
    request.to(url <> "/?v=" <> rest.api_version <> "&encoding=json")

  let builder =
    stratus.websocket(
      request: req,
      init: fn() { #(ActorState(seq: None), None) },
      loop: fn(msg, state, conn) {
        case msg {
          stratus.Text(msg) -> {
            logging.log(logging.Debug, "RECV: " <> msg)
            let _handle = handle_gateway_event(msg)
            actor.continue(state)
          }
          stratus.User(Close) -> {
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
      process.sleep(6000)

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
