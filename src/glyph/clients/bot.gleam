//// This contains the client with functions specifically made for Bot users.

import gleam/int
import gleam/list
import gleam/result
import gleam/string
import glyph/clients/api
import glyph/models/discord.{type GatewayIntent}
import glyph/network/gateway
import glyph/network/rest

/// Type that contains necessary information when communicating with the Discord API
pub type BotClient {
  BotClient(
    token_type: rest.TokenType,
    token: String,
    client_url: String,
    client_version: String,
    intents: Int,
    handlers: discord.EventHandler,
    api_client: api.APIClient,
  )
}

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
    handlers: discord.EventHandler(on_message_create: fn(_) { Ok(Nil) }),
    api_client: api.new(token, client_url, client_version),
  )
}

/// Send a message to a channel
pub fn send(b: BotClient, channel_id: String, message: String) {
  api.create_message(
    b.api_client,
    channel_id,
    discord.MessagePayload(content: message),
  )
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
  BotClient(..b, intents: intent_bits)
}

/// Register a handler for the MESSAGE_CREATE gateway event
pub fn on_message_create(
  b: BotClient,
  callback: fn(discord.Message) -> Result(Nil, discord.DiscordError),
) -> BotClient {
  BotClient(..b, handlers: discord.EventHandler(on_message_create: callback))
}

/// Initialize a client to begin communication with the gateway
pub fn initialize(b: BotClient) {
  let ws_url =
    b.api_client
    |> api.get_gateway_bot
    |> result.map(fn(gw_info) { gw_info.url })
    |> result.unwrap("")
    |> string.replace(each: "wss", with: "https")

  gateway.start_ws_loop(b.token, b.intents, ws_url, b.handlers)
}
