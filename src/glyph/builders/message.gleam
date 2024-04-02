//// This contains the builder functions for constructing a MessagePayload

import gleam/int
import gleam/list
import gleam/option.{None, Some}
import glyph/models/discord

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

pub fn content(
  m: discord.MessagePayload,
  content: String,
) -> discord.MessagePayload {
  discord.MessagePayload(..m, content: Some(content))
}

pub fn is_tts(m: discord.MessagePayload) -> discord.MessagePayload {
  discord.MessagePayload(..m, tts: Some(True))
}

pub fn embed(
  m: discord.MessagePayload,
  e: discord.Embed,
) -> discord.MessagePayload {
  let embeds = option.unwrap(m.embeds, or: [])

  discord.MessagePayload(..m, embeds: Some([e, ..embeds]))
}

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

pub fn stickers(
  m: discord.MessagePayload,
  sticker_ids: List(discord.Snowflake),
) -> discord.MessagePayload {
  discord.MessagePayload(..m, sticker_ids: Some(list.take(sticker_ids, 3)))
}

pub fn suppress_notifications(
  m: discord.MessagePayload,
) -> discord.MessagePayload {
  let suppress_notifs_flag = int.bitwise_shift_left(1, 12)

  discord.MessagePayload(..m, flags: Some(suppress_notifs_flag))
}

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
