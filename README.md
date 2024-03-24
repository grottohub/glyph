# glyph

I am primarily writing this to learn Gleam + the BEAM ecosystem, though I do plan on fully implementing all features.

I do not recommend using this for a "real" bot just yet - there's still many missing events and it is not prepared for highly available bots yet.

I _do_ recommend using this if you just want to play around with it and maybe even contribute!

## Roadmap

Just so you have an idea of what my focus will be the next few weeks:
- v0.1 - fully implement all gateway events <-- we are here!
- v0.2 - fully implement the REST client and its payloads (along with tests)
- v0.3 - start working on shard management, reconnect logic, etc.

[![Package Version](https://img.shields.io/hexpm/v/gliscord)](https://hex.pm/packages/glyph)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glyph/)

## Add Glyph to your project

```sh
gleam add glyph
```

## Basic example usage

```gleam
import gleam/io
import glyph/clients/api
import glyph/clients/bot
import glyph/models/discord
import envoy
import logging

pub type LogLevel {
  Debug
}

pub type Log {
  Level
}

@external(erlang, "logger", "set_primary_config")
fn set_logger_level(log: Log, level: LogLevel) -> Nil

pub fn main() {
  logging.configure()
  // NOTE:  This isn't strictly necessary at all (including the associated
  // stuff above). It's included just to show the debug logging.
  set_logger_level(Level, Debug)

  let discord_token = case envoy.get("DISCORD_TOKEN") {
    Ok(token) -> token
    Error(_) -> ""
  }

  io.println("DISCORD_TOKEN: " <> discord_token)

  // Create a new API client and invoke a function
  // Note: the intention for next release is to abstract these behind helper functions in the bot client
  // that way handlers can invoke them
  let some_channel = "1217259472096067625"
  let _ =
    api.new(discord_token, "https://github.com/grottohub/glyph", "0.0.1")
    |> api.create_message(some_channel, discord.MessagePayload("I'm alive!"))

  // Create a new bot and register its handlers
  bot.new(discord_token, "https://github.com/grottohub/glyph", "0.0.1")
  |> bot.set_intents([discord.GuildMessages, discord.MessageContent])
  |> bot.on_message_create(message_create_callback)
  |> bot.initialize
}

pub fn message_create_callback(
  msg: discord.Message,
) -> Result(Nil, discord.DiscordError) {
  logging.log(logging.Info, "Got: " <> msg.content)

  Ok(Nil)
}
```

Further documentation can be found at <https://hexdocs.pm/glyph>.
