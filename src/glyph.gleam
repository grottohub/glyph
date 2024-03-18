import gleam/io
import clients/rest as api
import network/rest
import envoy

pub fn main() {
  let discord_token = case envoy.get("DISCORD_TOKEN") {
    Ok(token) -> token
    Error(_) -> ""
  }

  io.println("DISCORD_TOKEN: " <> discord_token)

  let client =
    api.APIClient(rest.Bot, discord_token, "https://example.com", "0.0.1")

  client
  |> api.get_application
}
