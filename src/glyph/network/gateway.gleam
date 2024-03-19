//// This handles the logic for communicating with the Discord Gateway API. For more information: https://discord.com/developers/docs/topics/gateway

import gleam/dynamic
import gleam/erlang/process
import gleam/function
import gleam/option.{type Option, None}
import gleam/http/request
import gleam/io
import gleam/otp/actor
import gleam/result
import glyph/network/rest
import stratus
import logging

/// Structure of payloads between gateway and client: https://discord.com/developers/docs/topics/gateway-events#payload-structure
pub type GatewayEvent {
  GatewayEvent(
    op: Int,
    d: Option(dynamic.Dynamic),
    s: Option(Int),
    t: Option(String),
  )
}

pub type Msg {
  Close
  TimeUpdated(String)
}

pub fn decode_gateway_event(
  event_string,
) -> Result(GatewayEvent, List(dynamic.DecodeError)) {
  use op_code <- result.try(dynamic.field("op", dynamic.int)(event_string))

  case op_code {
    _ -> Ok(GatewayEvent(op: 0, d: None, s: None, t: None))
  }
}

pub fn start_ws_loop(_url: String) {
  let assert Ok(req) =
    request.to(
      "https://gateway.discord.gg"
      <> "/?v="
      <> rest.api_version
      <> "&encoding=json",
    )

  let builder =
    stratus.websocket(
      request: req,
      init: fn() { #(Nil, None) },
      loop: fn(msg, state, conn) {
        case msg {
          stratus.Text(msg) -> {
            logging.log(logging.Debug, "RECV: " <> msg)
            actor.continue(state)
          }
          stratus.User(Close) -> {
            let assert Ok(_) = stratus.close(conn)
            actor.Stop(process.Normal)
          }
          _ -> {
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
