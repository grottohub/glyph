//// This contains the client with functions specifically made for Bot users.

import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import gleam/otp/supervisor
import glyph/models/discord.{type GatewayIntent}
import glyph/internal/cache
import glyph/internal/encoders
import glyph/internal/decoders
import glyph/internal/network/gateway
import glyph/internal/network/rest
import logging

/// Generic bot error
pub type BotError {
  BotError(message: String)
}

/// Type that contains necessary information when communicating with the Discord API
pub type BotClient {
  BotClient(
    token_type: rest.TokenType,
    token: String,
    client_url: String,
    client_version: String,
    intents: Int,
    handlers: discord.EventHandler,
  )
}

/// Subject for the REST actor
pub type Bot =
  Subject(rest.RESTMessage)

/// Construct a new BotClient
pub fn new(
  token: String,
  client_url: String,
  client_version: String,
) -> BotClient {
  BotClient(
    token_type: rest.Bot,
    token: token,
    client_url: client_url,
    client_version: client_version,
    intents: 0,
    handlers: discord.EventHandler(on_message_create: fn(_, _) { Ok(Nil) }),
  )
}

/// Initialize a supervisor that manages the REST and WebSocket processes (aka the bot)
pub fn initialize(b: BotClient) -> Result(Subject(rest.RESTMessage), BotError) {
  let cache = cache.initialize()
  let rest_subj = process.new_subject()
  let rest_actor =
    rest.start_rest_actor(
      rest_subj,
      b.token,
      b.token_type,
      rest.UserAgent(b.client_url, b.client_version),
    )

  case rest_actor {
    Ok(ra) -> {
      use gateway_info <- result.try(get_gateway_info(ra))

      let supervisor_gateway_subj = process.new_subject()
      let gateway_actor =
        supervisor.worker(fn(_) {
          gateway.start_gateway_actor(
            supervisor_gateway_subj,
            ra,
            b.token,
            b.intents,
            gateway_info.url,
            b.handlers,
            cache,
          )
        })

      case
        supervisor.start(fn(children) {
          children
          |> supervisor.add(gateway_actor)
        })
      {
        Ok(_) -> Ok(ra)
        Error(e) ->
          Error(BotError(
            "Encountered error when starting supervisor: " <> string.inspect(e),
          ))
      }
    }
    Error(e) -> {
      Error(BotError(
        "Encountered error starting REST actor: " <> string.inspect(e),
      ))
    }
  }
}

/// Send a message to a channel
/// Converts a GatewayIntent into a bit field
fn intent_to_bits(intent: GatewayIntent) -> Int {
  case intent {
    discord.Guilds -> int.bitwise_shift_left(1, 0)
    discord.GuildMembers -> int.bitwise_shift_left(1, 1)
    discord.GuildModeration -> int.bitwise_shift_left(1, 2)
    discord.GuildEmojisAndStickers -> int.bitwise_shift_left(1, 3)
    discord.GuildIntegrations -> int.bitwise_shift_left(1, 4)
    discord.GuildWebhooks -> int.bitwise_shift_left(1, 5)
    discord.GuildInvites -> int.bitwise_shift_left(1, 6)
    discord.GuildVoiceStates -> int.bitwise_shift_left(1, 7)
    discord.GuildPresences -> int.bitwise_shift_left(1, 8)
    discord.GuildMessages -> int.bitwise_shift_left(1, 9)
    discord.GuildMessageReactions -> int.bitwise_shift_left(1, 10)
    discord.GuildMessageTyping -> int.bitwise_shift_left(1, 11)
    discord.DirectMessages -> int.bitwise_shift_left(1, 12)
    discord.DirectMessageReactions -> int.bitwise_shift_left(1, 13)
    discord.DirectMessageTyping -> int.bitwise_shift_left(1, 14)
    discord.MessageContent -> int.bitwise_shift_left(1, 15)
    discord.GuildScheduledEvents -> int.bitwise_shift_left(1, 16)
    discord.AutoModerationConfiguration -> int.bitwise_shift_left(1, 20)
    discord.AutoModerationExecution -> int.bitwise_shift_left(1, 21)
  }
}

/// Register intents for your bot
pub fn set_intents(b: BotClient, intents: List(GatewayIntent)) -> BotClient {
  let intent_bits =
    list.fold(intents, b.intents, fn(n, i) { n + intent_to_bits(i) })
  BotClient(..b, intents: intent_bits)
}

/// Get information for bootstrapping a gateway websocket connection
fn get_gateway_info(
  rest_subj: Subject(rest.RESTMessage),
) -> Result(discord.GetGatewayBot, BotError) {
  case rest.get(rest_subj, "/gateway/bot", "") {
    Ok(req_result) -> {
      case req_result {
        Ok(resp) -> {
          resp.body
          |> json.decode(using: decoders.get_gateway_bot_decoder())
          |> result.replace_error(BotError("Encountered error decoding JSON"))
        }
        Error(e) -> {
          Error(BotError(
            "Encountered error sending request: " <> string.inspect(e),
          ))
        }
      }
    }
    Error(e) -> {
      Error(BotError(
        "Encountered error calling REST process: " <> string.inspect(e),
      ))
    }
  }
}

/// Send a message to a channel
pub fn send(
  s: Subject(rest.RESTMessage),
  channel_id: String,
  message: discord.MessagePayload,
) {
  let message_json = encoders.message_to_json(message)
  let endpoint = "/channels/" <> channel_id <> "/messages"
  logging.log(logging.Debug, "Sending message: " <> message.content)

  let _ = rest.post(s, endpoint, message_json)
}

/// Register a handler for the MESSAGE_CREATE gateway event
pub fn on_message_create(
  b: BotClient,
  callback: fn(Bot, discord.Message) -> Result(Nil, discord.DiscordError),
) -> BotClient {
  BotClient(..b, handlers: discord.EventHandler(on_message_create: callback))
}
