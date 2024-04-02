//// This handles the logic for communicating with the Discord REST API. For more information: https://discord.com/developers/docs/reference#http-api

import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/http/response

/// The current supported version of the Discord API
pub const api_version = "10"

/// Acceptable values for an Authorization header
pub type TokenType {
  Bearer
  Bot
}

fn token_type_to_string(token_type: TokenType) -> String {
  case token_type {
    Bearer -> "Bearer"
    Bot -> "Bot"
  }
}

/// Discord expects your bot to provide a user agent, including a URL and a version.
pub type UserAgent {
  UserAgent(url: String, version: String)
}

fn user_agent_to_string(user_agent: UserAgent) -> String {
  "DiscordBot(" <> user_agent.url <> ", " <> user_agent.version <> ")"
}

pub type RESTClient {
  RESTClient(base_request: request.Request(String))
}

pub fn new(
  token_type: TokenType,
  token: String,
  user_agent: UserAgent,
) -> RESTClient {
  let req =
    request.new()
    |> request.set_host("discord.com")
    |> request.set_scheme(http.Https)
    |> set_bot_user_agent(user_agent)
    |> set_authorization(token_type, token)

  RESTClient(req)
}

pub fn set_bot_user_agent(
  r: request.Request(String),
  user_agent: UserAgent,
) -> request.Request(String) {
  r
  |> request.set_header("User-Agent", user_agent_to_string(user_agent))
}

pub fn set_authorization(
  r: request.Request(String),
  token_type: TokenType,
  token: String,
) -> request.Request(String) {
  r
  |> request.set_header(
    "Authorization",
    token_type_to_string(token_type) <> " " <> token,
  )
}

pub fn set_content_type(
  r: request.Request(String),
  content_type: String,
) -> request.Request(String) {
  r
  |> request.set_header("content-type", content_type)
}

fn send(
  rest: RESTClient,
  method: http.Method,
  endpoint: String,
  content_type: String,
  body: String,
) -> Result(response.Response(String), hackney.Error) {
  rest.base_request
  |> request.set_method(method)
  |> request.set_path("/api/v" <> api_version <> endpoint)
  |> request.set_header("content-type", content_type)
  |> request.set_body(body)
  |> hackney.send
}

pub fn get(
  rest: RESTClient,
  endpoint: String,
  body: String,
) -> Result(response.Response(String), hackney.Error) {
  send(rest, http.Get, endpoint, "application/json", body)
}

pub fn post(
  rest: RESTClient,
  endpoint: String,
  body: String,
) -> Result(response.Response(String), hackney.Error) {
  send(rest, http.Post, endpoint, "application/json", body)
}
