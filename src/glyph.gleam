import gleam/io
import gleam/result
import network/rest
import envoy

pub fn main() {
  let discord_token = case envoy.get("DISCORD_TOKEN") {
    Ok(token) -> token
    Error(_) -> ""
  }

  io.println("DISCORD_TOKEN: " <> discord_token)

  rest.request("https://example.com", "0.0.1", rest.Bot, discord_token)
  |> result.map_error(io.debug)
  |> result.nil_error()
}
