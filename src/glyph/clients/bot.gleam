//// This contains the client with functions specifically made for Bot users.

import gleam/result
import glyph/clients/api
import glyph/network/gateway
import glyph/network/rest

pub type BotClient {
  BotClient(
    token_type: rest.TokenType,
    token: String,
    client_url: String,
    client_version: String,
  )
}

pub fn test_ws_loop(b: BotClient) {
  let rest_client =
    api.APIClient(
      token_type: b.token_type,
      token: b.token,
      client_url: b.client_url,
      client_version: b.client_version,
    )

  let ws_url =
    rest_client
    |> api.get_gateway_bot
    |> result.map(fn(gw_info) { gw_info.url })
    |> result.unwrap("")

  gateway.start_ws_loop(ws_url)
}
