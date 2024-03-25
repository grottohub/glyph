//// This contains the client for communicating with Discord's REST API.

import gleam/erlang/process.{type Subject}
import gleam/http/request
import gleam/json.{type DecodeError}
import gleam/otp/actor
import gleam/result
import gleam/string
import glyph/models/discord
import glyph/models/decoders
import glyph/models/encoders
import glyph/network/rest
import logging

pub type APIError {
  APIError(message: String)
}

pub type APIClient {
  APIClient(
    token: String,
    token_type: rest.TokenType,
    user_agent: rest.UserAgent,
    base_request: request.Request(String),
  )
}

/// Construct a new APIClient
pub fn new(token: String, url: String, version: String) -> APIClient {
  let user_agent = rest.UserAgent(url: url, version: version)
  let base_request =
    rest.new()
    |> rest.set_authorization(rest.Bot, token)
    |> rest.set_bot_user_agent(user_agent)

  APIClient(
    token: token,
    token_type: rest.Bot,
    user_agent: user_agent,
    base_request: base_request,
  )
}

pub fn get_gateway_bot(c: APIClient) -> Result(discord.GetGatewayBot, APIError) {
  use resp <- result.try(
    c.base_request
    |> rest.get("/gateway/bot")
    |> result.replace_error(APIError(
      message: "Encountered error when sending request",
    )),
  )

  use gateway_info <- result.try(
    resp.body
    |> json.decode(using: decoders.get_gateway_bot_decoder())
    |> result.replace_error(APIError(
      message: "Encountered error when parsing JSON",
    )),
  )

  Ok(gateway_info)
}

pub fn create_message(
  c: APIClient,
  channel_id: String,
  message: discord.MessagePayload,
) -> Result(Nil, APIError) {
  use _resp <- result.try(
    c.base_request
    |> rest.set_content_type("application/json")
    |> rest.post(
      "/channels/" <> channel_id <> "/messages",
      encoders.message_to_json(message),
    )
    |> result.replace_error(APIError(
      message: "Encountered error when sending request",
    )),
  )

  Ok(Nil)
}
