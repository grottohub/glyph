//// This handles the logic for communicating with the Discord REST API. For more information: https://discord.com/developers/docs/reference#http-api

import gleam/dynamic
import gleam/result.{try}
import gleam/hackney
import gleam/http.{type Header}
import gleam/http/request as req
import gleam/http/response
import gleam/io
import gleam/json
import gleeunit/should
import models/api
import models/decoders

const base_url = "https://discord.com/api"

const api_version = "v10"

/// Acceptable values for an Authorization header
pub type TokenType {
  Bearer
  Bot
}

pub fn decode_application(
  json_string: String,
) -> Result(api.Application, json.DecodeError) {
  let user_decoder =
    decoders.user(
      api.User,
      dynamic.field("id", of: dynamic.string),
      dynamic.field("username", of: dynamic.string),
      dynamic.field("discriminator", of: dynamic.string),
      dynamic.optional_field("global_name", of: dynamic.string),
      dynamic.optional_field("avatar", of: dynamic.string),
      dynamic.optional_field("bot", of: dynamic.bool),
      dynamic.optional_field("system", of: dynamic.bool),
      dynamic.optional_field("mfa_enabled", of: dynamic.bool),
      dynamic.optional_field("banner", of: dynamic.string),
      dynamic.optional_field("accent_color", of: dynamic.int),
      dynamic.optional_field("locale", of: dynamic.string),
      dynamic.optional_field("email", of: dynamic.string),
      dynamic.optional_field("flags", of: dynamic.int),
      dynamic.optional_field("premium_type", of: dynamic.int),
      dynamic.optional_field("public_flags", of: dynamic.int),
      dynamic.optional_field("avatar_decoration", of: dynamic.string),
    )

  let member_decoder =
    decoders.member(
      api.Member,
      dynamic.field("membership_state", of: dynamic.int),
      dynamic.field("team_id", of: dynamic.string),
      dynamic.field("user", of: user_decoder),
      dynamic.field("role", of: dynamic.string),
    )

  let team_decoder =
    decoders.team(
      api.Team,
      dynamic.field("id", of: dynamic.string),
      dynamic.optional_field("icon", of: dynamic.string),
      dynamic.field("members", of: dynamic.list(member_decoder)),
      dynamic.field("name", of: dynamic.string),
      dynamic.field("owner_user_id", of: dynamic.string),
    )

  let install_params_decoder =
    decoders.install_params(
      api.InstallParams,
      dynamic.field("scopes", dynamic.list(dynamic.string)),
      dynamic.field("permissions", dynamic.string),
    )

  let application_decoder =
    decoders.application(
      api.Application,
      dynamic.field("id", of: dynamic.string),
      dynamic.field("name", of: dynamic.string),
      dynamic.optional_field("icon", of: dynamic.string),
      dynamic.field("description", of: dynamic.string),
      dynamic.optional_field("rpc_origins", of: dynamic.list(dynamic.string)),
      dynamic.field("bot_public", of: dynamic.bool),
      dynamic.field("bot_require_code_grant", of: dynamic.bool),
      dynamic.optional_field("bot", of: user_decoder),
      dynamic.optional_field("terms_of_service_url", of: dynamic.string),
      dynamic.optional_field("privacy_policy_url", of: dynamic.string),
      dynamic.optional_field("owner", of: user_decoder),
      dynamic.optional_field("summary", of: dynamic.string),
      dynamic.field("verify_key", of: dynamic.string),
      dynamic.optional_field("team", of: team_decoder),
      dynamic.optional_field("guild_id", of: dynamic.string),
      dynamic.optional_field("primary_sku_id", of: dynamic.string),
      dynamic.optional_field("slug", of: dynamic.string),
      dynamic.optional_field("cover_image", of: dynamic.string),
      dynamic.optional_field("flags", of: dynamic.int),
      dynamic.optional_field("approximate_guild_count", of: dynamic.int),
      dynamic.optional_field("redirect_uris", of: dynamic.list(dynamic.string)),
      dynamic.optional_field("interactions_endpoint_url", of: dynamic.string),
      dynamic.optional_field(
        "role_connections_verification_url",
        of: dynamic.string,
      ),
      dynamic.optional_field("tags", of: dynamic.list(dynamic.string)),
      dynamic.optional_field("install_params", of: install_params_decoder),
      dynamic.optional_field("custom_install_url", of: dynamic.string),
    )

  json.decode(from: json_string, using: application_decoder)
}

pub fn request(
  ua_url: String,
  version: String,
  token_type: TokenType,
  token: String,
) {
  let token_type_str = case token_type {
    Bearer -> "Bearer"
    Bot -> "Bot"
  }

  let assert Ok(req) =
    req.to(base_url <> "/" <> api_version <> "/applications/@me")

  use response <- try(
    req
    |> req.prepend_header("Authorization", token_type_str <> " " <> token)
    |> req.prepend_header(
      "User-Agent",
      "DiscordBot(" <> ua_url <> ", " <> version <> ")",
    )
    |> hackney.send,
  )

  response
  |> io.debug

  response.body
  |> decode_application
  |> io.debug

  response.status
  |> should.equal(200)

  response
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json"))

  Ok(response)
}
