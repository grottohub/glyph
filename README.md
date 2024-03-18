# glyph

I am primarily writing this to learn Gleam + the BEAM ecosystem, though I do plan on fully implementing all features.

I will further document how to use this once I have gotten the basic Bot functionality to a point that I like.

[![Package Version](https://img.shields.io/hexpm/v/gliscord)](https://hex.pm/packages/glyph)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glyph/)

```sh
gleam add glyph
```

```gleam
import gleam/io
import glyph/clients/api
import glyph/network/rest
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
  |> io.debug
}
```

Further documentation can be found at <https://hexdocs.pm/gliscord>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
