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

## Basic Ping-Pong example

The following code sets up a bot that _replies_ to `!ping` with `Pong!` and `!pong` with `Ping!`.

Note: any code related to the `logging` package below is not necessary, but may help us debug if you encounter issues.

```gleam
import envoy
import gleam/erlang/process
import glyph/clients/bot
import glyph/models/discord
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
  set_logger_level(Level, Debug)

  let assert Ok(discord_token) = envoy.get("DISCORD_TOKEN")
  let bot_name = "YOUR_BOT_NAME"
  let bot_version = "YOUR_BOT_VERSION"

  // Create a new bot and register its handlers
  let assert Ok(bot) =
    bot.new(discord_token, bot_name, bot_version)
    |> bot.set_intents([discord.GuildMessages, discord.MessageContent])
    |> bot.on_message_create(message_create_callback)
    |> bot.initialize

  process.sleep_forever()
}

fn pong(bot: discord.BotClient, msg: discord.Message) {
  let response = 
    message.new()
    |> message.content("Pong!")
    |> message.reply_to(msg)
  
  let _ = bot.send(bot, msg.channel_id, response)

  Nil
}

fn ping(bot: discord.BotClient, msg: discord.Message) {
  let response = 
    message.new()
    |> message.content("Ping!")
    |> message.reply_to(msg)
  
  let _ = bot.send(bot, msg.channel_id, response)

  Nil
}

pub fn message_create_handler(
  bot: discord.BotClient,
  msg: discord.Message,
) -> Result(Nil, discord.DiscordError) {
  case string.starts_with(msg.content, "!ping") {
    True -> pong(bot, msg)
    False -> Nil
  }

  case string.starts_with(msg.content, "!pong") {
    True -> ping(bot, msg)
    False -> Nil
  }

  Ok(Nil)
}
```

## Advanced Examples

As I develop Glyph, I will do my best to keep [Scribe](https://github.com/grottohub/scribe/) up to date with examples for all supported features.

Further documentation can be found at <https://hexdocs.pm/glyph>.
