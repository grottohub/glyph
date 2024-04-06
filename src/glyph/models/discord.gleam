//// This contains all types needed to communicate with either the Gateway or REST API.

import gleam/dynamic
import gleam/dict
import gleam/option.{type Option}
import glyph/internal/network/rest

/// Generic Discord Error
pub type DiscordError

/// The data structure Discord uses for UUIDs: https://discord.com/developers/docs/reference#snowflakes
pub type Snowflake =
  String

/// Model for a Discord Application: https://discord.com/developers/docs/resources/application
/// Note to self: summary is deprecated and will be removed in v11
pub type Application {
  Application(
    id: Snowflake,
    name: String,
    icon: Option(String),
    description: String,
    rpc_origins: Option(List(String)),
    bot_public: Bool,
    bot_require_code_grant: Bool,
    bot: Option(User),
    terms_of_service_url: Option(String),
    privacy_policy_url: Option(String),
    owner: Option(User),
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

/// Model for a Discord User: https://discord.com/developers/docs/resources/user#user-object
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

pub type RoleTag {
  RoleTag(
    bot_id: Option(Snowflake),
    integration_id: Option(Snowflake),
    premium_subscriber: Option(String),
    // TODO: check this
    subscription_listing_id: Option(Snowflake),
    available_for_purchase: Option(String),
    // TODO: check this
    guild_connections: Option(String),
  )
  // TODO: check this
}

//https://discord.com/developers/docs/topics/permissions#role-object
pub type Role {
  Role(
    id: Snowflake,
    name: String,
    color: Int,
    hoist: Bool,
    icon: Option(String),
    unicode_emoji: Option(String),
    position: Int,
    permissions: String,
    managed: Bool,
    mentionable: Bool,
    tags: Option(List(RoleTag)),
    flags: Int,
  )
}

// https://discord.com/developers/docs/resources/channel#channel-mention-object
pub type ChannelMention {
  ChannelMention(
    id: Snowflake,
    guild_id: Snowflake,
    kind: Int,
    // TODO: check this!! in docs it is named as 'type'
    name: String,
  )
}

// https://discord.com/developers/docs/resources/channel#attachment-object
pub type Attachment {
  Attachment(
    id: Snowflake,
    filename: String,
    description: Option(String),
    content_type: Option(String),
    size: Int,
    url: String,
    proxy_url: String,
    height: Option(Int),
    width: Option(Int),
    ephemeral: Option(Bool),
    duration_secs: Option(Float),
    waveform: Option(String),
    flags: Option(Int),
  )
}

// https://discord.com/developers/docs/resources/channel#embed-object
pub type Embed {
  Embed(
    title: Option(String),
    kind: Option(String),
    description: Option(String),
    url: Option(String),
    timestamp: Option(String),
    // TODO: check timestamp
    color: Option(Int),
  )
  // TODO: rest...
}

pub type Emoji {
  Emoji(
    id: Option(Snowflake),
    name: Option(String),
    roles: Option(List(Role)),
    user: Option(User),
    require_colons: Option(Bool),
    managed: Option(Bool),
    animated: Option(Bool),
    available: Option(Bool),
  )
}

// https://discord.com/developers/docs/resources/channel#reaction-object
pub type Reaction {
  Reaction(
    count: Int,
    count_details: Int,
    me: Bool,
    me_burst: Bool,
    emoji: Emoji,
    burst_colors: List(Int),
  )
  // TODO: check
}

pub type Noonce {
  Noonce
  // String(String)
  // Integer(Int)
}

// https://discord.com/developers/docs/resources/channel#message-object-message-types
// TODO
pub type MessageType =
  Int

// https://discord.com/developers/docs/resources/channel#message-object-message-activity-structure
pub type MessageActivity {
  // TODO
  MessageActivity
}

// https://discord.com/developers/docs/resources/channel#message-reference-object-message-reference-structure
pub type MessageReference {
  MessageReference(
    message_id: Option(Snowflake),
    channel_id: Option(Snowflake),
    guild_id: Option(Snowflake),
    fail_if_not_exists: Option(Bool),
  )
}

// https://discord.com/developers/docs/resources/channel#message-object-message-flags
pub type MessageFlags {
  // TODO
  MessageFlags
}

// https://discord.com/developers/docs/resources/channel#message-interaction-metadata-object-message-interaction-metadata-structure
pub type MessageInteractionMetadata {
  MessageInteractionMetadata(
    id: Snowflake,
    kind: Int,
    // TODO: change to enum
    user_id: Snowflake,
    authorizing_integration_owners: dict.Dict(String, Int),
    original_response_message_id: Option(Snowflake),
    interacted_message_id: Option(Snowflake),
    triggering_interaction_metadata: Option(MessageInteractionMetadata),
  )
  // TODO: check recursion when decoding
}

pub type GuildMember {
  GuildMember(
    user: Option(User),
    nick: Option(String),
    avatar: Option(User),
    roles: List(Snowflake),
    // TODO: ISO8601 timestamp
    joined_at: String,
    // TODO: ISO8601 timestamp
    premium_since: String,
    deaf: Bool,
    mute: Bool,
    // TODO: change to enum
    flags: Int,
    pending: Option(Bool),
    permissions: Option(String),
    // TODO: ISO8601 timestamp
    communication_disabled_until: Option(String),
  )
}

// https://discord.com/developers/docs/interactions/receiving-and-responding#message-interaction-object-message-interaction-structure
pub type MessageInteraction {
  MessageInteraction(
    id: Snowflake,
    kind: Int,
    // TODO: change to enum
    name: String,
    user: User,
    member: Option(GuildMember),
  )
}

pub type Overwrite {
  Overwrite(
    id: Snowflake,
    // TODO: change to enum
    kind: Int,
    allow: String,
    deny: String,
  )
}

pub type ThreadMetedata {
  ThreadMetedata(
    archived: Bool,
    auto_archive_duration: Int,
    // TODO: timestamp
    archive_timestamp: String,
    locked: Bool,
    invitable: Option(Bool),
    // TODO: timestamp
    create_timestamp: Option(String),
  )
}

pub type ForumTag {
  ForumTag(
    id: Snowflake,
    name: String,
    moderated: Bool,
    emoji_id: Option(Snowflake),
    emoji_name: Option(String),
  )
}

pub type DefaultReaction {
  DefaultReaction(emoji_id: Option(Snowflake), emoji_name: Option(String))
}

// https://discord.com/developers/docs/resources/channel#channel-object
pub type Channel {
  Channel(
    id: Snowflake,
    // TODO: change to enum
    kind: Int,
    guild_id: Option(Snowflake),
    position: Option(Int),
    permission_overwrites: Option(List(Overwrite)),
    name: Option(String),
    topic: Option(String),
    nsfw: Option(Bool),
    last_message_id: Option(Snowflake),
    bitrate: Option(Int),
    user_limit: Option(Int),
    rate_limit_per_user: Option(Int),
    recipients: Option(List(User)),
    icon: Option(String),
    owner_id: Option(Snowflake),
    application_id: Option(Snowflake),
    managed: Option(Bool),
    parent_id: Option(Snowflake),
    // TODO: ISO8601 timestamp
    last_pin_timestamp: Option(String),
    rtc_region: Option(String),
    video_quality_mode: Option(Int),
    message_count: Option(Int),
    member_count: Option(Int),
    thread_metadata: Option(ThreadMetedata),
    member: Option(Member),
    default_auto_archive_duration: Option(Int),
    permissions: Option(String),
    flags: Option(Int),
    total_message_sent: Option(Int),
    available_tags: Option(List(ForumTag)),
    applied_tags: Option(List(Snowflake)),
    default_reaction_emoji: Option(DefaultReaction),
    default_thread_rate_limit_per_user: Option(Int),
    default_sort_order: Option(String),
    default_forum_layout: Option(Int),
  )
}

// https://discord.com/developers/docs/interactions/message-components#component-object
// pub type MessageComponent {
//   MessageComponent
// }

// https://discord.com/developers/docs/resources/sticker#sticker-item-object
pub type StickerItem {
  StickerItem(id: Snowflake, name: String, format_type: Int)
}

// https://discord.com/developers/docs/resources/sticker#sticker-object
pub type Sticker {
  Sticker(
    id: Snowflake,
    pack_id: Option(Snowflake),
    name: String,
    description: Option(String),
    tags: String,
    asset: Option(String),
    // TODO
    kind: Int,
    format_type: Option(Int),
    available: Option(Bool),
    guild_id: Option(Snowflake),
    user: Option(User),
    sort_value: Option(Int),
  )
}

// https://discord.com/developers/docs/resources/channel#role-subscription-data-object
pub type RoleSubscription {
  RoleSubscription(
    role_subscription_listing_id: Snowflake,
    tier_name: String,
    total_months_subscribed: Int,
    is_renewal: Bool,
  )
}

// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
pub type Resolved {
  Resolved(
    users: Option(dict.Dict(Snowflake, User)),
    members: Option(dict.Dict(Snowflake, Member)),
    roles: Option(dict.Dict(Snowflake, Role)),
    // TODO: check
    channels: Option(dict.Dict(Snowflake, Channel)),
    // TODO: check
    messages: Option(dict.Dict(Snowflake, Message)),
    attachments: Option(dict.Dict(Snowflake, Attachment)),
  )
}

/// Model for a Message object: https://discord.com/developers/docs/resources/channel#message-object
/// TODO: add remaining fields
pub type Message {
  Message(
    id: Snowflake,
    channel_id: Snowflake,
    author: User,
    content: String,
    // when this message was sent
    timestamp: String,
    // TODO: ISO8601 timestamp
    // when this message was edited (or null if never)
    edited_timestamp: Option(String),
    // TODO: ISO8601 timestamp
    tts: Bool,
    mention_everyone: Bool,
    // users specifically mentioned in the message
    mentions: List(User),
    // TODO: check user model
    // roles specifically mentioned in this message
    mention_roles: List(Role),
    // channels specifically mentioned in this message
    mention_channels: Option(List(ChannelMention)),
    // any attached files
    attachments: List(Attachment),
    // any embedded content
    embeds: List(Embed),
    // reactions to the message
    reactions: Option(List(Reaction)),
    // used for validating a message was sent
    // noonce: Option(Noonce), TODO: how to decode that?
    // whether this message is pinned
    pinned: Bool,
    // if the message is generated by a webhook, this is the webhook's id
    webhook_id: Option(Snowflake),
    // Thw API discord names this field as 'type' but it is a reserved kayword in Gleam
    // type of message
    // TODO: for now this is just a int but we need to parse this field to own custom type for readiblity
    kind: Int,
    // TODO: for now this is just a int but we need to parse this field to own custom type for readiblity
    // sent with Rich Presence-related chat embeds
    activity: Option(Int),
    // sent with Rich Presence-related chat embeds
    application: Option(Application),
    //if the message is an Interaction or application-owned webhook, this is the id of the application
    application_id: Option(Snowflake),
    // data showing the source of a crosspost, channel follow add, pin, or reply message
    message_reference: Option(MessageReference),
    // message flags combined as a bitfield
    // TODO: for now this is just a int but we need to parse this field to own custom type for readiblity
    flags: Option(Int),
    // the message associated with the message_reference
    referenced_message: Option(Message),
    // In preview. Sent if the message is sent as a result of an interaction
    interaction_metadata: Option(MessageInteractionMetadata),
    // Deprecated in favor of interaction_metadata; sent if the message is a response to an interaction
    interaction: Option(MessageInteraction),
    // the thread that was started from this message, includes thread member object
    thread: Option(Channel),
    // sent if the message contains components like buttons, action rows, or other interactive components
    components: Option(List(Int)),
    // sent if the message contains stickers
    sticker_items: Option(List(StickerItem)),
    // Deprecated: the stickers sent with the message
    stickers: Option(List(Sticker)),
    // A generally increasing integer (there may be gaps or duplicates) that represents the approximate 
    // position of the message in a thread, it can be used to estimate the relative position of the message 
    // in a thread in company with total_message_sent on parent thread
    position: Option(Int),
    // data of the role subscription purchase or renewal that prompted this ROLE_SUBSCRIPTION_PURCHASE message
    role_subscription_data: Option(RoleSubscription),
    // data for users, members, channels, and roles in the message's auto-populated select menus
    resolved: Option(Resolved),
  )
}

/// Model for the payload when creating a message: https://discord.com/developers/docs/resources/channel#create-message
/// TODO: add remaining fields
pub type MessagePayload {
  MessagePayload(content: String)
}

/// Model for a Team object: https://discord.com/developers/docs/topics/teams#data-models-team-object
pub type Team {
  Team(
    id: Snowflake,
    icon: Option(String),
    members: List(Member),
    name: String,
    owner_user_id: Snowflake,
  )
}

/// Model for a Team Member object: https://discord.com/developers/docs/topics/teams#data-models-team-member-object
pub type Member {
  Member(membership_state: Int, team_id: Snowflake, user: User, role: String)
}

/// Model for Membership State: https://discord.com/developers/docs/topics/teams#data-models-membership-state-enum
pub type MembershipState {
  INVITED
  // -> 1
  ACCEPTED
  // -> 2
}

/// Model for Install Params: https://discord.com/developers/docs/resources/application#install-params-object
pub type InstallParams {
  InstallParams(scopes: List(String), permissions: String)
}

/// Model for Get Gateway Bot: https://discord.com/developers/docs/topics/gateway#get-gateway-bot
pub type GetGatewayBot {
  GetGatewayBot(
    url: String,
    shards: Int,
    session_start_limit: SessionStartLimit,
  )
}

/// Model for Session Start Limit Object: https://discord.com/developers/docs/topics/gateway#session-start-limit-object
pub type SessionStartLimit {
  SessionStartLimit(
    total: Int,
    remaining: Int,
    reset_after: Int,
    max_concurrency: Int,
  )
}

/// Structure of payloads between gateway and client: https://discord.com/developers/docs/topics/gateway-events#payload-structure
pub type GatewayEvent {
  GatewayEvent(op: Int, d: dynamic.Dynamic, s: Option(Int), t: Option(String))
}

// The following are Gateway data models for the data contained within the `d` field of a GatewayEvent

pub type EventHandler {
  EventHandler(
    on_message_create: fn(BotClient, Message) -> Result(Nil, DiscordError),
  )
}

/// Structure of a Hello event: https://discord.com/developers/docs/topics/gateway#hello-event
pub type HelloEvent {
  HelloEvent(heartbeat_interval: Int)
}

/// Structure of a Ready event: https://discord.com/developers/docs/topics/gateway-events#ready-ready-event-fields
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

/// The following are gateway intents which represent what events you subscribe to: https://discord.com/developers/docs/topics/gateway#gateway-intents
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
