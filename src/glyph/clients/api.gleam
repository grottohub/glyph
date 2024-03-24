//// This contains the client for communicating with Discord's REST API.

import gleam/json.{type DecodeError}
import gleam/result
import glyph/models/discord
import glyph/models/decoders
import glyph/models/encoders
import glyph/network/rest

pub type APIClient {
  APIClient(
    token_type: rest.TokenType,
    token: String,
    client_url: String,
    client_version: String,
  )
}

/// Construct a new APIClient
pub fn new(
  token: String,
  client_url: String,
  client_version: String,
) -> APIClient {
  APIClient(
    token_type: rest.Bot,
    token: token,
    client_url: client_url,
    client_version: client_version,
  )
}

pub type APIError {
  HackneyError
  DecodeError
}

pub fn get_application(c: APIClient) -> Result(discord.Application, APIError) {
  use resp <- result.try(
    rest.new()
    |> rest.set_authorization(c.token_type, c.token)
    |> rest.set_bot_user_agent(c.client_url, c.client_version)
    |> rest.get("/applications/@me")
    |> result.replace_error(HackneyError),
  )

  use app <- result.try(
    resp.body
    |> json.decode(using: decoders.application_decoder())
    |> result.replace_error(DecodeError),
  )

  Ok(app)
}

pub fn get_gateway_bot(c: APIClient) -> Result(discord.GetGatewayBot, APIError) {
  use resp <- result.try(
    rest.new()
    |> rest.set_authorization(c.token_type, c.token)
    |> rest.set_bot_user_agent(c.client_url, c.client_version)
    |> rest.get("/gateway/bot")
    |> result.replace_error(HackneyError),
  )

  use gateway_info <- result.try(
    resp.body
    |> json.decode(using: decoders.get_gateway_bot_decoder())
    |> result.replace_error(DecodeError),
  )

  Ok(gateway_info)
}

pub fn create_message(
  c: APIClient,
  channel_id: String,
  message: discord.MessagePayload,
) -> Result(Nil, APIError) {
  use _resp <- result.try(
    rest.new()
    |> rest.set_authorization(c.token_type, c.token)
    |> rest.set_bot_user_agent(c.client_url, c.client_version)
    |> rest.set_content_type("application/json")
    |> rest.post(
      "/channels/" <> channel_id <> "/messages",
      encoders.message_to_json(message),
    )
    |> result.replace_error(HackneyError),
  )

  Ok(Nil)
}
