# Glyph

I am primarily writing this to learn Gleam + the BEAM ecosystem, though I do plan on fully implementing all features.

I do not recommend using this for a "real" bot just yet - there's still many missing events and it is not prepared for highly available bots yet.

I _do_ recommend using this if you just want to play around with it and maybe even contribute!

## Roadmap

To see what is planned for a certain release, go to the Issues section and filter by Milestone.

[![Package Version](https://img.shields.io/hexpm/v/glyph)](https://hex.pm/packages/glyph)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glyph/)

## Add Glyph to your project

```sh
gleam add glyph
```

## Basic example usage

```gleam
import gleam/io
import glyph/clients/bot
import glyph/models/discord
import gleam/erlang/process
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

  let assert Ok(discord_token) = envoy.get("DISCORD_TOKEN")
  let channel_id = "YOUR_CHANNEL_ID"
  let bot_name = "YOUR_BOT_NAME"
  let bot_version = "YOUR_BOT_VERSION"

  io.println("DISCORD_TOKEN: " <> discord_token)

  // Create a new bot and register its handlers
  let assert Ok(bot) =
    bot.new(discord_token, bot_name, bot_version)
    |> bot.set_intents([discord.GuildMessages, discord.MessageContent])
    |> bot.on_message_create(message_create_callback)
    |> bot.initialize

  bot.send(bot, channel_id, discord.MessagePayload("I'm alive!"))

  // Wait forever to prevent program termination
  process.sleep_forever()
}

pub fn message_create_callback(
  bot: bot.Bot,
  msg: discord.Message,
) -> Result(Nil, discord.DiscordError) {
  case msg {
    discord.Message(..) as msg if msg.content == "ping" -> {
      bot.send(bot, msg.channel_id, discord.MessagePayload("pong!"))
      Ok(Nil)
    }
    _ -> Ok(Nil)
  }
}
```

Further documentation can be found at <https://hexdocs.pm/glyph>.
