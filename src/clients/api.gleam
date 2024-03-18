//// This contains the client for communicating with Discord's REST discord.

import gleam/hackney.{type Error as HackneyError}
import gleam/json.{type DecodeError}
import gleam/result
import models/discord
import models/decoders
import network/rest

pub type Client {
  APIClient(
    token_type: rest.TokenType,
    token: String,
    client_url: String,
    client_version: String,
  )
}

pub type APIError {
  HackneyError
  DecodeError
}

pub fn get_application(c: Client) -> Result(discord.Application, APIError) {
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
