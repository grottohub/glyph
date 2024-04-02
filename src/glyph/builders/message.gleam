//// This contains the builder functions for constructing a MessagePayload
//// 
//// ## Examples
//// 
//// ```gleam
//// message.new()
//// |> message.content("Example message")
//// ```
//// 
//// ```gleam
//// let example_embed =
////  embed.new()
////  |> embed.title("Example embed")
////  |> embed.description("Example description")
//// 
//// message.new()
//// |> message.embed(example_embed)
//// ```

import gleam/int
import gleam/list
import gleam/option.{None, Some}
import glyph/models/discord

/// Construct a new, empty MessagePayload
pub fn new() -> discord.MessagePayload {
  discord.MessagePayload(
    content: None,
    tts: None,
    embeds: None,
    allowed_mentions: None,
    message_reference: None,
    sticker_ids: None,
    flags: None,
    nonce: None,
    enforce_nonce: None,
  )
}

/// Set the content of the message
pub fn content(
  m: discord.MessagePayload,
  content: String,
) -> discord.MessagePayload {
  discord.MessagePayload(..m, content: Some(content))
}

/// Sets the `tts` flag to `True` for Text-to-Speech messages
pub fn is_tts(m: discord.MessagePayload) -> discord.MessagePayload {
  discord.MessagePayload(..m, tts: Some(True))
}

/// Add an Embed to the message
pub fn embed(
  m: discord.MessagePayload,
  e: discord.Embed,
) -> discord.MessagePayload {
  let embeds = option.unwrap(m.embeds, or: [])

  discord.MessagePayload(..m, embeds: Some(list.append(embeds, [e])))
}

/// Sets the message to be a reply to a given Message
pub fn reply_to(
  m: discord.MessagePayload,
  msg: discord.Message,
) -> discord.MessagePayload {
  let ref =
    discord.MessageReference(
      message_id: Some(msg.id),
      channel_id: Some(msg.channel_id),
      guild_id: None,
      fail_if_not_exists: Some(True),
    )

  discord.MessagePayload(..m, message_reference: Some(ref))
}

/// Send a sticker with your message (maximum of 3)
/// 
/// Note: since you cannot extract sticker IDs from the Discord
/// application right now, you will need to wait for Glyph
/// to implement the proper API interactions.
pub fn stickers(
  m: discord.MessagePayload,
  sticker_ids: List(discord.Snowflake),
) -> discord.MessagePayload {
  discord.MessagePayload(..m, sticker_ids: Some(list.take(sticker_ids, 3)))
}

/// Sets a flag to suppress notifications for this message
pub fn suppress_notifications(
  m: discord.MessagePayload,
) -> discord.MessagePayload {
  let suppress_notifs_flag = int.bitwise_shift_left(1, 12)

  discord.MessagePayload(..m, flags: Some(suppress_notifs_flag))
}

/// If your message contains @everyone, this must be set
pub fn mentions_everyone(m: discord.MessagePayload) -> discord.MessagePayload {
  let allowed_mentions =
    option.unwrap(m.allowed_mentions, or: empty_allowed_mentions())
  let updated_mentions =
    discord.AllowedMentions(
      ..allowed_mentions,
      parse: [discord.Everyone, ..allowed_mentions.parse],
    )

  discord.MessagePayload(..m, allowed_mentions: Some(updated_mentions))
}

/// If your message contains a mention of a user, this must be set
pub fn mentions_users(m: discord.MessagePayload) -> discord.MessagePayload {
  let allowed_mentions =
    option.unwrap(m.allowed_mentions, or: empty_allowed_mentions())
  let updated_mentions =
    discord.AllowedMentions(
      ..allowed_mentions,
      parse: [discord.Users, ..allowed_mentions.parse],
    )

  discord.MessagePayload(..m, allowed_mentions: Some(updated_mentions))
}

/// If your message contains a mention of a role, this must be set
pub fn mentions_roles(m: discord.MessagePayload) -> discord.MessagePayload {
  let allowed_mentions =
    option.unwrap(m.allowed_mentions, or: empty_allowed_mentions())
  let updated_mentions =
    discord.AllowedMentions(
      ..allowed_mentions,
      parse: [discord.Roles, ..allowed_mentions.parse],
    )

  discord.MessagePayload(..m, allowed_mentions: Some(updated_mentions))
}

fn empty_allowed_mentions() -> discord.AllowedMentions {
  discord.AllowedMentions(parse: [], roles: [], users: [], replied_user: False)
}
