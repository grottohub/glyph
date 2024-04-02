//// This contains all types needed to communicate with either the Gateway or REST API.

import gleam/dynamic
import gleam/option.{type Option}
import glyph/internal/network/rest

/// Generic Discord Error
pub type DiscordError

/// The [data structure](https://discord.com/developers/docs/reference#snowflakes) Discord uses for UUIDs.
pub type Snowflake =
  String

/// Model for a Discord [Application](https://discord.com/developers/docs/resources/application).
/// 
/// TODO: summary is deprecated and will be removed in v11
pub type Application {
  Application(
    id: Snowflake,
    name: String,
    icon: Option(String),
    description: String,
    rpc_origins: Option(List(String)),
    bot_public: Bool,
    bot_require_code_grant: Bool,
    bot: Option(Bot),
    terms_of_service_url: Option(String),
    privacy_policy_url: Option(String),
    owner: Option(Owner),
    summary: Option(String),
    verify_key: String,
    team: Option(Team),
    guild_id: Option(Snowflake),
    primary_sku_id: Option(Snowflake),
    slug: Option(String),
    cover_image: Option(String),
    flags: Option(Int),
    approximate_guild_count: Option(Int),
    redirect_uris: Option(List(String)),
    interactions_endpoint_url: Option(String),
    role_connections_verification_url: Option(String),
    tags: Option(List(String)),
    install_params: Option(InstallParams),
    custom_install_url: Option(String),
  )
}

/// Model for a partial Application received in the Ready event
pub type ReadyApplication {
  ReadyApplication(id: Snowflake, flags: Int)
}

/// Model for a Discord [User](https://discord.com/developers/docs/resources/user#user-object).
/// 
/// Some additional fields marked as optional here due to the use of partial user objects
/// in other areas of the API.
pub type User {
  User(
    id: Snowflake,
    username: String,
    discriminator: String,
    global_name: Option(String),
    avatar: Option(String),
    bot: Option(Bool),
    system: Option(Bool),
    mfa_enabled: Option(Bool),
    banner: Option(String),
    accent_color: Option(Int),
    locale: Option(String),
    email: Option(String),
    flags: Option(Int),
    premium_type: Option(Int),
    public_flags: Option(Int),
    avatar_decoration: Option(String),
  )
}

pub type Bot =
  User

pub type Owner =
  User

/// Model for a [Message](https://discord.com/developers/docs/resources/channel#message-object) object as received from the gateway.
/// 
/// TODO: add remaining fields
pub type Message {
  Message(
    id: Snowflake,
    channel_id: Snowflake,
    author: User,
    content: String,
    tts: Bool,
    mention_everyone: Bool,
    pinned: Bool,
    message_type: Int,
  )
}

/// Model for the [payload](https://discord.com/developers/docs/resources/channel#create-message) when creating a message.
/// 
/// TODO: message components (will come w/ interactions / commands), files
pub type MessagePayload {
  MessagePayload(
    content: Option(String),
    tts: Option(Bool),
    embeds: Option(List(Embed)),
    allowed_mentions: Option(AllowedMentions),
    message_reference: Option(MessageReference),
    sticker_ids: Option(List(Snowflake)),
    flags: Option(Int),
    nonce: Option(String),
    enforce_nonce: Option(Bool),
  )
}

/// This contains information needed for a `message_reference` attached
/// to a `MessagePayload`. Needed when replying to a message.
pub type MessageReference {
  MessageReference(
    message_id: Option(Snowflake),
    channel_id: Option(Snowflake),
    guild_id: Option(Snowflake),
    fail_if_not_exists: Option(Bool),
  )
}

/// This contains information regarding the mentions contained within
/// a message's content.
pub type AllowedMentions {
  AllowedMentions(
    parse: List(MentionType),
    roles: List(Snowflake),
    users: List(Snowflake),
    replied_user: Bool,
  )
}

/// The supported types of mentions.
pub type MentionType {
  Roles
  Users
  Everyone
}

pub fn mention_type_to_string(m: MentionType) -> String {
  case m {
    Roles -> "roles"
    Users -> "users"
    Everyone -> "everyone"
  }
}

/// Model for an [embed](https://discord.com/developers/docs/resources/channel#embed-object) that can be
/// attached to a message.
pub type Embed {
  Embed(
    title: Option(String),
    description: Option(String),
    url: Option(String),
    timestamp: Option(String),
    color: Option(Int),
    footer: Option(EmbedFooter),
    image: Option(EmbedImage),
    thumbnail: Option(EmbedThumbnail),
    video: Option(EmbedVideo),
    provider: Option(EmbedProvider),
    author: Option(EmbedAuthor),
    fields: Option(List(EmbedField)),
  )
}

/// Supported information for an embed's footer.
pub type EmbedFooter {
  EmbedFooter(
    text: String,
    icon_url: Option(String),
    proxy_icon_url: Option(String),
  )
}

/// The information necessary to send an image with an embed.
pub type EmbedImage {
  EmbedImage(
    url: String,
    proxy_url: Option(String),
    height: Option(Int),
    width: Option(Int),
  )
}

/// The information necessary to send a thumbnail with an embed.
pub type EmbedThumbnail {
  EmbedThumbnail(
    url: String,
    proxy_url: Option(String),
    height: Option(Int),
    width: Option(Int),
  )
}

/// The information necessary to send a video with an embed.
pub type EmbedVideo {
  EmbedVideo(
    url: Option(String),
    proxy_url: Option(String),
    height: Option(Int),
    width: Option(Int),
  )
}

/// Metadata about the source of the embedded data.
pub type EmbedProvider {
  EmbedProvider(name: Option(String), url: Option(String))
}

/// Metadata about the author of the embedded data.
pub type EmbedAuthor {
  EmbedAuthor(
    name: String,
    url: Option(String),
    icon_url: Option(String),
    proxy_icon_url: Option(String),
  )
}

/// Generic fields that can be added to an embed.
pub type EmbedField {
  EmbedField(name: String, value: String, inline: Option(Bool))
}

/// Model for a [Team](https://discord.com/developers/docs/topics/teams#data-models-team-object) object.
pub type Team {
  Team(
    id: Snowflake,
    icon: Option(String),
    members: List(Member),
    name: String,
    owner_user_id: Snowflake,
  )
}

/// Model for a [Team Member](https://discord.com/developers/docs/topics/teams#data-models-team-member-object) object.
pub type Member {
  Member(membership_state: Int, team_id: Snowflake, user: User, role: String)
}

/// Model for [Membership State](https://discord.com/developers/docs/topics/teams#data-models-membership-state-enum).
pub type MembershipState {
  INVITED
  // -> 1
  ACCEPTED
  // -> 2
}

/// Model for [Install Params](https://discord.com/developers/docs/resources/application#install-params-object).
pub type InstallParams {
  InstallParams(scopes: List(String), permissions: String)
}

/// Model for the [response](https://discord.com/developers/docs/topics/gateway#get-gateway-bot) received from `/gateway/bot`.
pub type GetGatewayBot {
  GetGatewayBot(
    url: String,
    shards: Int,
    session_start_limit: SessionStartLimit,
  )
}

/// Model for [Session Start Limit Object](https://discord.com/developers/docs/topics/gateway#session-start-limit-object).
pub type SessionStartLimit {
  SessionStartLimit(
    total: Int,
    remaining: Int,
    reset_after: Int,
    max_concurrency: Int,
  )
}

/// Top-level structure of [payloads](https://discord.com/developers/docs/topics/gateway-events#payload-structure) between gateway and client.
pub type GatewayEvent {
  GatewayEvent(op: Int, d: dynamic.Dynamic, s: Option(Int), t: Option(String))
}

/// These represent Glyph's supported gateway events and the necessary function signature
/// for callbacks that get passed in to the `BotClient`.
pub type EventHandler {
  EventHandler(
    on_message_create: fn(BotClient, Message) -> Result(Nil, DiscordError),
  )
}

// The following are Gateway data models for the data contained within the `d` field of a GatewayEvent

/// Structure of a [Hello](https://discord.com/developers/docs/topics/gateway#hello-event) event.
pub type HelloEvent {
  HelloEvent(heartbeat_interval: Int)
}

/// Structure of a [Ready](https://discord.com/developers/docs/topics/gateway-events#ready-ready-event-fields) event.
pub type ReadyEvent {
  ReadyEvent(
    v: Int,
    user: User,
    guilds: dynamic.Dynamic,
    session_id: String,
    resume_gateway_url: String,
    shard: Option(List(Int)),
    application: ReadyApplication,
  )
}

/// The following are [gateway intents](https://discord.com/developers/docs/topics/gateway#gateway-intents) which represent what events you subscribe to.
pub type GatewayIntent {
  Guilds
  GuildMembers
  GuildModeration
  GuildEmojisAndStickers
  GuildIntegrations
  GuildWebhooks
  GuildInvites
  GuildVoiceStates
  GuildPresences
  GuildMessages
  GuildMessageReactions
  GuildMessageTyping
  DirectMessages
  DirectMessageReactions
  DirectMessageTyping
  MessageContent
  GuildScheduledEvents
  AutoModerationConfiguration
  AutoModerationExecution
}

/// Type that contains necessary information when communicating with the Discord API
pub type BotClient {
  BotClient(
    token_type: rest.TokenType,
    token: String,
    client_url: String,
    client_version: String,
    intents: Int,
    handlers: EventHandler,
    rest_client: rest.RESTClient,
  )
}
