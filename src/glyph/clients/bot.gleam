//// This contains the client with functions specifically made for Bot users.

import gleam/erlang/process
import gleam/int
import gleam/json
import gleam/list
import gleam/otp/supervisor
import gleam/result
import gleam/option.{Some}
import glyph/internal/cache
import glyph/internal/decoders
import glyph/internal/encoders
import glyph/internal/network/gateway
import glyph/internal/network/rest
import glyph/models/discord.{type BotClient, type GatewayIntent}

/// Generic bot error
pub type BotError {
  BotError(message: String)
}

/// Construct a new BotClient
pub fn new(
  token: String,
  client_url: String,
  client_version: String,
) -> BotClient {
  let rest_client =
    rest.new(rest.Bot, token, rest.UserAgent(client_url, client_version))
  discord.BotClient(
    token_type: rest.Bot,
    token: token,
    client_url: client_url,
    client_version: client_version,
    intents: 0,
    handlers: discord.EventHandler(on_message_create: fn(_, _) { Ok(Nil) }),
    rest_client: rest_client,
  )
}

/// Initialize a supervisor that manages the WebSocket process (aka the bot)
pub fn initialize(bot: BotClient) -> Result(BotClient, BotError) {
  let cache = cache.initialize()
  use gateway_info <- result.try(get_gateway_info(bot))

  let supervisor_gateway_subj = process.new_subject()
  let gateway_actor =
    supervisor.worker(fn(_) {
      gateway.start_gateway_actor(
        supervisor_gateway_subj,
        bot,
        gateway_info.url,
        cache,
      )
    })

  use _supervisor_started <- result.try(
    supervisor.start(fn(children) {
      children
      |> supervisor.add(gateway_actor)
    })
    |> result.replace_error(BotError("Encountered error starting supervisor")),
  )

  Ok(bot)
}

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
  discord.BotClient(..b, intents: intent_bits)
}

/// Get information for bootstrapping a gateway websocket connection
fn get_gateway_info(bot: BotClient) -> Result(discord.GetGatewayBot, BotError) {
  use resp <- result.try(
    rest.get(bot.rest_client, "/gateway/bot", "")
    |> result.replace_error(BotError("Encountered error when sending request")),
  )

  use gateway_info <- result.try(
    resp.body
    |> json.decode(using: decoders.get_gateway_bot_decoder())
    |> result.replace_error(BotError("Encountered error when parsing JSON")),
  )

  Ok(gateway_info)
}

fn generate_nonce() -> String {
  random.int(random.min_int, random.max_int)
  |> random.random_sample
  |> int.to_string
}

/// Send a message to a channel.
/// 
/// For constructing a message, see [the message builder](https://hexdocs.pm/glyph/glyph/builders/message.html).
/// For constructing an embed, see [the embed builder](https://hexdocs.pm/glyph/glyph/builders/embed.html).
pub fn send(bot: BotClient, channel_id: String, message: discord.MessagePayload) {
  let message =
    discord.MessagePayload(
      ..message,
      nonce: Some(generate_nonce()),
      enforce_nonce: Some(True),
    )
  let message_json = encoders.message_to_json(message)
  let endpoint = "/channels/" <> channel_id <> "/messages"

  rest.post(bot.rest_client, endpoint, message_json)
}

/// Register a handler for the MESSAGE_CREATE gateway event.
/// 
/// The callback function must accept a `BotClient` as its first argument,
/// and is provided a `Message` argument as part of the `MESSAGE_CREATE` event.
pub fn on_message_create(
  bot: BotClient,
  callback: fn(BotClient, discord.Message) -> Result(Nil, discord.DiscordError),
) -> BotClient {
  discord.BotClient(
    ..bot,
    handlers: discord.EventHandler(on_message_create: callback),
  )
}
