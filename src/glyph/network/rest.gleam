//// This handles the logic for communicating with the Discord REST API. For more information: https://discord.com/developers/docs/reference#http-api

import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/otp/actor
import gleam/string
import logging

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
  r: request.Request(String),
  method: http.Method,
  endpoint: String,
  body: String,
) -> Result(response.Response(String), hackney.Error) {
  r
  |> request.set_method(method)
  |> request.set_path("/api/v" <> api_version <> endpoint)
  |> request.set_body(body)
  |> hackney.send
}

pub fn get(
  subj: Subject(RESTMessage),
  endpoint: String,
  body: String,
) -> Result(
  Result(response.Response(String), hackney.Error),
  process.CallError(Result(response.Response(String), hackney.Error)),
) {
  case process.try_call(subj, Get(_, endpoint, body), 5000) {
    Ok(r) -> Ok(r)
    Error(e) -> {
      logging.log(
        logging.Error,
        "Encountered error sending POST "
          <> endpoint
          <> ": "
          <> string.inspect(e),
      )
      Error(e)
    }
  }
}

pub fn post(
  subj: Subject(RESTMessage),
  endpoint: String,
  body: String,
) -> Result(
  Result(response.Response(String), hackney.Error),
  process.CallError(Result(response.Response(String), hackney.Error)),
) {
  case process.try_call(subj, Post(_, endpoint, body), 5000) {
    Ok(r) -> Ok(r)
    Error(e) -> {
      logging.log(
        logging.Error,
        "Encountered error sending POST "
          <> endpoint
          <> ": "
          <> string.inspect(e),
      )
      Error(e)
    }
  }
}

pub type RESTMessage {
  Get(
    reply_with: Subject(Result(response.Response(String), hackney.Error)),
    endpoint: String,
    body: String,
  )
  Post(
    reply_with: Subject(Result(response.Response(String), hackney.Error)),
    endpoint: String,
    body: String,
  )
  Shutdown
}

type RESTState {
  RESTState(
    token: String,
    token_type: TokenType,
    user_agent: UserAgent,
    base_request: request.Request(String),
  )
}

fn initial_state(
  token: String,
  token_type: TokenType,
  user_agent: UserAgent,
) -> RESTState {
  let base_request =
    request.new()
    |> request.set_scheme(http.Https)
    |> request.set_host("discord.com")
    |> set_authorization(token_type, token)
    |> set_bot_user_agent(user_agent)
    |> set_content_type("application/json")

  RESTState(token, token_type, user_agent, base_request)
}

fn handle_rest_message(
  message: RESTMessage,
  state: RESTState,
) -> actor.Next(RESTMessage, RESTState) {
  logging.log(logging.Debug, "Received " <> string.inspect(message))
  case message {
    Get(subj, endpoint, body) -> {
      logging.log(logging.Debug, "Sending GET " <> endpoint)
      let resp =
        state.base_request
        |> send(http.Get, endpoint, body)
      process.send(subj, resp)
      actor.continue(state)
    }
    Post(subj, endpoint, body) -> {
      logging.log(logging.Debug, "Sending POST " <> endpoint)
      let resp =
        state.base_request
        |> send(http.Post, endpoint, body)
      process.send(subj, resp)
      actor.continue(state)
    }
    Shutdown -> actor.Stop(process.Normal)
  }
}

pub fn start_rest_actor(
  rest_subj: Subject(RESTMessage),
  token: String,
  token_type: TokenType,
  user_agent: UserAgent,
) -> Result(Subject(RESTMessage), actor.StartError) {
  actor.start_spec(actor.Spec(
    init: fn() {
      let selector =
        process.new_selector()
        |> process.selecting(rest_subj, function.identity)

      actor.Ready(initial_state(token, token_type, user_agent), selector)
    },
    loop: handle_rest_message,
    init_timeout: 1000,
  ))
}
