import gleam/dynamic
import gleam/list
import glyph/models/discord

fn all_errors(result: Result(a, dynamic.DecodeErrors)) -> dynamic.DecodeErrors {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}

pub fn decode_user(
  dyn: dynamic.Dynamic,
) -> Result(discord.User, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("username", dynamic.string)(dyn),
    dynamic.field("discriminator", dynamic.string)(dyn),
    dynamic.optional_field("global_name", dynamic.string)(dyn),
    dynamic.optional_field("avatar", dynamic.string)(dyn),
    dynamic.optional_field("bot", dynamic.bool)(dyn),
    dynamic.optional_field("system", dynamic.bool)(dyn),
    dynamic.optional_field("mfa_enabled", dynamic.bool)(dyn),
    dynamic.optional_field("banner", dynamic.string)(dyn),
    dynamic.optional_field("accent_color", dynamic.int)(dyn),
    dynamic.optional_field("locale", dynamic.string)(dyn),
    dynamic.optional_field("email", dynamic.string)(dyn),
    dynamic.optional_field("flags", dynamic.int)(dyn),
    dynamic.optional_field("premium_type", dynamic.int)(dyn),
    dynamic.optional_field("public_flags", dynamic.int)(dyn),
    dynamic.optional_field("avatar_decoration", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12), Ok(a13), Ok(a14), Ok(a15), Ok(a16) ->
      Ok(discord.User(
        a1,
        a2,
        a3,
        a4,
        a5,
        a6,
        a7,
        a8,
        a9,
        a10,
        a11,
        a12,
        a13,
        a14,
        a15,
        a16,
      ))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
          all_errors(a13),
          all_errors(a14),
          all_errors(a15),
          all_errors(a16),
        ]),
      )
  }
}

pub fn decode_ready_application(
  dyn: dynamic.Dynamic,
) -> Result(discord.ReadyApplication, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("flags", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2) -> Ok(discord.ReadyApplication(a1, a2))
    a1, a2 -> Error(list.concat([all_errors(a1), all_errors(a2)]))
  }
}

pub fn decode_install_params(
  dyn: dynamic.Dynamic,
) -> Result(discord.InstallParams, dynamic.DecodeErrors) {
  case
    dynamic.field("scopes", dynamic.list(dynamic.string))(dyn),
    dynamic.field("permissions", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2) -> Ok(discord.InstallParams(a1, a2))
    a1, a2 -> Error(list.concat([all_errors(a1), all_errors(a2)]))
  }
}

pub fn decode_message_payload(
  dyn: dynamic.Dynamic,
) -> Result(discord.MessagePayload, dynamic.DecodeErrors) {
  case dynamic.field("content", dynamic.string)(dyn) {
    Ok(a1) -> Ok(discord.MessagePayload(a1))
    a1 -> Error(list.concat([all_errors(a1)]))
  }
}

pub fn decode_team(
  dyn: dynamic.Dynamic,
) -> Result(discord.Team, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.optional_field("icon", dynamic.string)(dyn),
    dynamic.field("members", dynamic.list(decode_member))(dyn),
    dynamic.field("name", dynamic.string)(dyn),
    dynamic.field("owner_user_id", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5) ->
      Ok(discord.Team(a1, a2, a3, a4, a5))
    a1, a2, a3, a4, a5 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
        ]),
      )
  }
}

pub fn decode_member(
  dyn: dynamic.Dynamic,
) -> Result(discord.Member, dynamic.DecodeErrors) {
  case
    dynamic.field("membership_state", dynamic.int)(dyn),
    dynamic.field("team_id", dynamic.string)(dyn),
    dynamic.field("user", decode_user)(dyn),
    dynamic.field("role", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4) -> Ok(discord.Member(a1, a2, a3, a4))
    a1, a2, a3, a4 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
        ]),
      )
  }
}

pub fn decode_session_start_limit(
  dyn: dynamic.Dynamic,
) -> Result(discord.SessionStartLimit, dynamic.DecodeErrors) {
  case
    dynamic.field("total", dynamic.int)(dyn),
    dynamic.field("remaining", dynamic.int)(dyn),
    dynamic.field("reset_after", dynamic.int)(dyn),
    dynamic.field("max_concurrency", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4) ->
      Ok(discord.SessionStartLimit(a1, a2, a3, a4))
    a1, a2, a3, a4 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
        ]),
      )
  }
}

pub fn decode_get_gateway_bot(
  dyn: dynamic.Dynamic,
) -> Result(discord.GetGatewayBot, dynamic.DecodeErrors) {
  case
    dynamic.field("url", dynamic.string)(dyn),
    dynamic.field("shards", dynamic.int)(dyn),
    dynamic.field("session_start_limit", decode_session_start_limit)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3) -> Ok(discord.GetGatewayBot(a1, a2, a3))
    a1, a2, a3 ->
      Error(list.concat([all_errors(a1), all_errors(a2), all_errors(a3)]))
  }
}

pub fn decode_gateway_event(
  dyn: dynamic.Dynamic,
) -> Result(discord.GatewayEvent, dynamic.DecodeErrors) {
  case
    dynamic.field("op", dynamic.int)(dyn),
    dynamic.field("d", dynamic.dynamic)(dyn),
    dynamic.optional_field("s", dynamic.int)(dyn),
    dynamic.optional_field("t", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4) -> Ok(discord.GatewayEvent(a1, a2, a3, a4))
    a1, a2, a3, a4 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
        ]),
      )
  }
}

pub fn decode_hello_event(
  dyn: dynamic.Dynamic,
) -> Result(discord.HelloEvent, dynamic.DecodeErrors) {
  case dynamic.field("heartbeat_interval", dynamic.int)(dyn) {
    Ok(a1) -> Ok(discord.HelloEvent(a1))
    a1 -> Error(list.concat([all_errors(a1)]))
  }
}

pub fn decode_ready_event(
  dyn: dynamic.Dynamic,
) -> Result(discord.ReadyEvent, dynamic.DecodeErrors) {
  case
    dynamic.field("v", dynamic.int)(dyn),
    dynamic.field("user", decode_user)(dyn),
    dynamic.field("guilds", dynamic.dynamic)(dyn),
    dynamic.field("session_id", dynamic.string)(dyn),
    dynamic.field("resume_gateway_url", dynamic.string)(dyn),
    dynamic.optional_field("shard", dynamic.list(dynamic.int))(dyn),
    dynamic.field("application", decode_ready_application)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7) ->
      Ok(discord.ReadyEvent(a1, a2, a3, a4, a5, a6, a7))
    a1, a2, a3, a4, a5, a6, a7 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
        ]),
      )
  }
}

pub fn decode_role_tag(
  dyn: dynamic.Dynamic,
) -> Result(discord.RoleTag, dynamic.DecodeErrors) {
  case
    dynamic.optional_field("bot_id", dynamic.string)(dyn),
    dynamic.optional_field("integration_id", dynamic.string)(dyn),
    dynamic.optional_field("premium_subscriber", dynamic.string)(dyn),
    dynamic.optional_field("subscription_listing_id", dynamic.string)(dyn),
    dynamic.optional_field("available_for_purchase", dynamic.string)(dyn),
    dynamic.optional_field("guild_connections", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6) ->
      Ok(discord.RoleTag(a1, a2, a3, a4, a5, a6))
    a1, a2, a3, a4, a5, a6 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
        ]),
      )
  }
}

pub fn decode_role(
  dyn: dynamic.Dynamic,
) -> Result(discord.Role, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("name", dynamic.string)(dyn),
    dynamic.field("color", dynamic.int)(dyn),
    dynamic.field("hoist", dynamic.bool)(dyn),
    dynamic.optional_field("icon", dynamic.string)(dyn),
    dynamic.optional_field("unicode_emoji", dynamic.string)(dyn),
    dynamic.field("position", dynamic.int)(dyn),
    dynamic.field("permissions", dynamic.string)(dyn),
    dynamic.field("managed", dynamic.bool)(dyn),
    dynamic.field("mentionable", dynamic.bool)(dyn),
    dynamic.optional_field("tags", dynamic.list(decode_role_tag))(dyn),
    dynamic.field("flags", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12) ->
      Ok(discord.Role(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
        ]),
      )
  }
}

pub fn decode_channel_mention(
  dyn: dynamic.Dynamic,
) -> Result(discord.ChannelMention, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("guild_id", dynamic.string)(dyn),
    dynamic.field("type", dynamic.int)(dyn),
    dynamic.field("name", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4) -> Ok(discord.ChannelMention(a1, a2, a3, a4))
    a1, a2, a3, a4 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
        ]),
      )
  }
}

pub fn decode_attachment(
  dyn: dynamic.Dynamic,
) -> Result(discord.Attachment, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("filename", dynamic.string)(dyn),
    dynamic.optional_field("description", dynamic.string)(dyn),
    dynamic.optional_field("content_type", dynamic.string)(dyn),
    dynamic.field("size", dynamic.int)(dyn),
    dynamic.field("url", dynamic.string)(dyn),
    dynamic.field("proxy_url", dynamic.string)(dyn),
    dynamic.optional_field("height", dynamic.int)(dyn),
    dynamic.optional_field("width", dynamic.int)(dyn),
    dynamic.optional_field("ephemeral", dynamic.bool)(dyn),
    dynamic.optional_field("duration_secs", dynamic.float)(dyn),
    dynamic.optional_field("waveform", dynamic.string)(dyn),
    dynamic.optional_field("flags", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12), Ok(a13) ->
      Ok(discord.Attachment(
        a1,
        a2,
        a3,
        a4,
        a5,
        a6,
        a7,
        a8,
        a9,
        a10,
        a11,
        a12,
        a13,
      ))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
          all_errors(a13),
        ]),
      )
  }
}

pub fn decode_embed(
  dyn: dynamic.Dynamic,
) -> Result(discord.Embed, dynamic.DecodeErrors) {
  case
    dynamic.optional_field("title", dynamic.string)(dyn),
    dynamic.optional_field("type", dynamic.string)(dyn),
    dynamic.optional_field("description", dynamic.string)(dyn),
    dynamic.optional_field("url", dynamic.string)(dyn),
    dynamic.optional_field("timestamp", dynamic.string)(dyn),
    dynamic.optional_field("color", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6) ->
      Ok(discord.Embed(a1, a2, a3, a4, a5, a6))
    a1, a2, a3, a4, a5, a6 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
        ]),
      )
  }
}

pub fn decode_emoji(
  dyn: dynamic.Dynamic,
) -> Result(discord.Emoji, dynamic.DecodeErrors) {
  case
    dynamic.optional_field("id", dynamic.string)(dyn),
    dynamic.optional_field("name", dynamic.string)(dyn),
    dynamic.optional_field("roles", dynamic.list(decode_role))(dyn),
    dynamic.optional_field("user", decode_user)(dyn),
    dynamic.optional_field("require_colons", dynamic.bool)(dyn),
    dynamic.optional_field("managed", dynamic.bool)(dyn),
    dynamic.optional_field("animated", dynamic.bool)(dyn),
    dynamic.optional_field("available", dynamic.bool)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8) ->
      Ok(discord.Emoji(a1, a2, a3, a4, a5, a6, a7, a8))
    a1, a2, a3, a4, a5, a6, a7, a8 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
        ]),
      )
  }
}

pub fn decode_message_reference(
  dyn: dynamic.Dynamic,
) -> Result(discord.MessageReference, dynamic.DecodeErrors) {
  case
    dynamic.optional_field("message_id", dynamic.string)(dyn),
    dynamic.optional_field("channel_id", dynamic.string)(dyn),
    dynamic.optional_field("guild_id", dynamic.string)(dyn),
    dynamic.optional_field("fail_if_not_exists", dynamic.bool)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4) ->
      Ok(discord.MessageReference(a1, a2, a3, a4))
    a1, a2, a3, a4 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
        ]),
      )
  }
}

pub fn decode_message_interaction_metadata(
  dyn: dynamic.Dynamic,
) -> Result(discord.MessageInteractionMetadata, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("type", dynamic.int)(dyn),
    dynamic.field("user_id", dynamic.string)(dyn),
    dynamic.field(
      "authorizing_integration_owners",
      dynamic.dict(dynamic.string, dynamic.int),
    )(dyn),
    dynamic.optional_field("original_response_message_id", dynamic.string)(dyn),
    dynamic.optional_field("interacted_message_id", dynamic.string)(dyn),
    dynamic.optional_field(
      "triggering_interaction_metadata",
      decode_message_interaction_metadata,
    )(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7) ->
      Ok(discord.MessageInteractionMetadata(a1, a2, a3, a4, a5, a6, a7))
    a1, a2, a3, a4, a5, a6, a7 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
        ]),
      )
  }
}

pub fn decode_guild_member(
  dyn: dynamic.Dynamic,
) -> Result(discord.GuildMember, dynamic.DecodeErrors) {
  case
    dynamic.optional_field("user", decode_user)(dyn),
    dynamic.optional_field("nick", dynamic.string)(dyn),
    dynamic.optional_field("avatar", decode_user)(dyn),
    dynamic.field("roles", dynamic.list(dynamic.string))(dyn),
    dynamic.field("joined_at", dynamic.string)(dyn),
    dynamic.field("premium_since", dynamic.string)(dyn),
    dynamic.field("deaf", dynamic.bool)(dyn),
    dynamic.field("mute", dynamic.bool)(dyn),
    dynamic.field("flags", dynamic.int)(dyn),
    dynamic.optional_field("pending", dynamic.bool)(dyn),
    dynamic.optional_field("permissions", dynamic.string)(dyn),
    dynamic.optional_field("communication_disabled_until", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12) ->
      Ok(discord.GuildMember(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
        ]),
      )
  }
}

pub fn decode_message_interaction(
  dyn: dynamic.Dynamic,
) -> Result(discord.MessageInteraction, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("type", dynamic.int)(dyn),
    dynamic.field("name", dynamic.string)(dyn),
    dynamic.field("user", decode_user)(dyn),
    dynamic.optional_field("member", decode_guild_member)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5) ->
      Ok(discord.MessageInteraction(a1, a2, a3, a4, a5))
    a1, a2, a3, a4, a5 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
        ]),
      )
  }
}

pub fn decode_overwrite(
  dyn: dynamic.Dynamic,
) -> Result(discord.Overwrite, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("type", dynamic.int)(dyn),
    dynamic.field("allow", dynamic.string)(dyn),
    dynamic.field("deny", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4) -> Ok(discord.Overwrite(a1, a2, a3, a4))
    a1, a2, a3, a4 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
        ]),
      )
  }
}

pub fn decode_thread_metedata(
  dyn: dynamic.Dynamic,
) -> Result(discord.ThreadMetedata, dynamic.DecodeErrors) {
  case
    dynamic.field("archived", dynamic.bool)(dyn),
    dynamic.field("auto_archive_duration", dynamic.int)(dyn),
    dynamic.field("archive_timestamp", dynamic.string)(dyn),
    dynamic.field("locked", dynamic.bool)(dyn),
    dynamic.optional_field("invitable", dynamic.bool)(dyn),
    dynamic.optional_field("create_timestamp", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6) ->
      Ok(discord.ThreadMetedata(a1, a2, a3, a4, a5, a6))
    a1, a2, a3, a4, a5, a6 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
        ]),
      )
  }
}

pub fn decode_forum_tag(
  dyn: dynamic.Dynamic,
) -> Result(discord.ForumTag, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("name", dynamic.string)(dyn),
    dynamic.field("moderated", dynamic.bool)(dyn),
    dynamic.optional_field("emoji_id", dynamic.string)(dyn),
    dynamic.optional_field("emoji_name", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5) ->
      Ok(discord.ForumTag(a1, a2, a3, a4, a5))
    a1, a2, a3, a4, a5 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
        ]),
      )
  }
}

pub fn decode_default_reaction(
  dyn: dynamic.Dynamic,
) -> Result(discord.DefaultReaction, dynamic.DecodeErrors) {
  case
    dynamic.optional_field("emoji_id", dynamic.string)(dyn),
    dynamic.optional_field("emoji_name", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2) -> Ok(discord.DefaultReaction(a1, a2))
    a1, a2 -> Error(list.concat([all_errors(a1), all_errors(a2)]))
  }
}

pub fn decode_sticker_item(
  dyn: dynamic.Dynamic,
) -> Result(discord.StickerItem, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("name", dynamic.string)(dyn),
    dynamic.field("format_type", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3) -> Ok(discord.StickerItem(a1, a2, a3))
    a1, a2, a3 ->
      Error(list.concat([all_errors(a1), all_errors(a2), all_errors(a3)]))
  }
}

pub fn decode_sticker(
  dyn: dynamic.Dynamic,
) -> Result(discord.Sticker, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.optional_field("pack_id", dynamic.string)(dyn),
    dynamic.field("name", dynamic.string)(dyn),
    dynamic.optional_field("description", dynamic.string)(dyn),
    dynamic.field("tags", dynamic.string)(dyn),
    dynamic.optional_field("asset", dynamic.string)(dyn),
    dynamic.field("type", dynamic.int)(dyn),
    dynamic.optional_field("format_type", dynamic.int)(dyn),
    dynamic.optional_field("available", dynamic.bool)(dyn),
    dynamic.optional_field("guild_id", dynamic.string)(dyn),
    dynamic.optional_field("user", decode_user)(dyn),
    dynamic.optional_field("sort_value", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12) ->
      Ok(discord.Sticker(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
        ]),
      )
  }
}

pub fn decode_role_subscription(
  dyn: dynamic.Dynamic,
) -> Result(discord.RoleSubscription, dynamic.DecodeErrors) {
  case
    dynamic.field("role_subscription_listing_id", dynamic.string)(dyn),
    dynamic.field("tier_name", dynamic.string)(dyn),
    dynamic.field("total_months_subscribed", dynamic.int)(dyn),
    dynamic.field("is_renewal", dynamic.bool)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4) ->
      Ok(discord.RoleSubscription(a1, a2, a3, a4))
    a1, a2, a3, a4 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
        ]),
      )
  }
}

pub fn decode_reaction(
  dyn: dynamic.Dynamic,
) -> Result(discord.Reaction, dynamic.DecodeErrors) {
  case
    dynamic.field("count", dynamic.int)(dyn),
    dynamic.field("count_details", dynamic.int)(dyn),
    dynamic.field("me", dynamic.bool)(dyn),
    dynamic.field("me_burst", dynamic.bool)(dyn),
    dynamic.field("emoji", decode_emoji)(dyn),
    dynamic.field("burst_colors", dynamic.list(dynamic.int))(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6) ->
      Ok(discord.Reaction(a1, a2, a3, a4, a5, a6))
    a1, a2, a3, a4, a5, a6 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
        ]),
      )
  }
}

pub fn decode_application(
  dyn: dynamic.Dynamic,
) -> Result(discord.Application, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("name", dynamic.string)(dyn),
    dynamic.optional_field("icon", dynamic.string)(dyn),
    dynamic.field("description", dynamic.string)(dyn),
    dynamic.optional_field("rpc_origins", dynamic.list(dynamic.string))(dyn),
    dynamic.field("bot_public", dynamic.bool)(dyn),
    dynamic.field("bot_require_code_grant", dynamic.bool)(dyn),
    dynamic.optional_field("bot", decode_user)(dyn),
    dynamic.optional_field("terms_of_service_url", dynamic.string)(dyn),
    dynamic.optional_field("privacy_policy_url", dynamic.string)(dyn),
    dynamic.optional_field("owner", decode_user)(dyn),
    dynamic.optional_field("summary", dynamic.string)(dyn),
    dynamic.field("verify_key", dynamic.string)(dyn),
    dynamic.optional_field("team", decode_team)(dyn),
    dynamic.optional_field("guild_id", dynamic.string)(dyn),
    dynamic.optional_field("primary_sku_id", dynamic.string)(dyn),
    dynamic.optional_field("slug", dynamic.string)(dyn),
    dynamic.optional_field("cover_image", dynamic.string)(dyn),
    dynamic.optional_field("flags", dynamic.int)(dyn),
    dynamic.optional_field("approximate_guild_count", dynamic.int)(dyn),
    dynamic.optional_field("redirect_uris", dynamic.list(dynamic.string))(dyn),
    dynamic.optional_field("interactions_endpoint_url", dynamic.string)(dyn),
    dynamic.optional_field("role_connections_verification_url", dynamic.string)(
      dyn,
    ),
    dynamic.optional_field("tags", dynamic.list(dynamic.string))(dyn),
    dynamic.optional_field("install_params", decode_install_params)(dyn),
    dynamic.optional_field("custom_install_url", dynamic.string)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12), Ok(a13), Ok(a14), Ok(a15), Ok(a16), Ok(a17), Ok(a18), Ok(
      a19,
    ), Ok(a20), Ok(a21), Ok(a22), Ok(a23), Ok(a24), Ok(a25), Ok(a26) ->
      Ok(discord.Application(
        a1,
        a2,
        a3,
        a4,
        a5,
        a6,
        a7,
        a8,
        a9,
        a10,
        a11,
        a12,
        a13,
        a14,
        a15,
        a16,
        a17,
        a18,
        a19,
        a20,
        a21,
        a22,
        a23,
        a24,
        a25,
        a26,
      ))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
          all_errors(a13),
          all_errors(a14),
          all_errors(a15),
          all_errors(a16),
          all_errors(a17),
          all_errors(a18),
          all_errors(a19),
          all_errors(a20),
          all_errors(a21),
          all_errors(a22),
          all_errors(a23),
          all_errors(a24),
          all_errors(a25),
          all_errors(a26),
        ]),
      )
  }
}

pub fn decode_message(
  dyn: dynamic.Dynamic,
) -> Result(discord.Message, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("channel_id", dynamic.string)(dyn),
    dynamic.field("author", decode_user)(dyn),
    dynamic.field("content", dynamic.string)(dyn),
    dynamic.field("timestamp", dynamic.string)(dyn),
    dynamic.optional_field("edited_timestamp", dynamic.string)(dyn),
    dynamic.field("tts", dynamic.bool)(dyn),
    dynamic.field("mention_everyone", dynamic.bool)(dyn),
    dynamic.field("mentions", dynamic.list(decode_user))(dyn),
    dynamic.field("mention_roles", dynamic.list(decode_role))(dyn),
    dynamic.optional_field(
      "mention_channels",
      dynamic.list(decode_channel_mention),
    )(dyn),
    dynamic.field("attachments", dynamic.list(decode_attachment))(dyn),
    dynamic.field("embeds", dynamic.list(decode_embed))(dyn),
    dynamic.optional_field("reactions", dynamic.list(decode_reaction))(dyn),
    dynamic.field("pinned", dynamic.bool)(dyn),
    dynamic.optional_field("webhook_id", dynamic.string)(dyn),
    dynamic.field("type", dynamic.int)(dyn),
    dynamic.optional_field("activity", dynamic.int)(dyn),
    dynamic.optional_field("application", decode_application)(dyn),
    dynamic.optional_field("application_id", dynamic.string)(dyn),
    dynamic.optional_field("message_reference", decode_message_reference)(dyn),
    dynamic.optional_field("flags", dynamic.int)(dyn),
    dynamic.optional_field("referenced_message", decode_message)(dyn),
    dynamic.optional_field(
      "interaction_metadata",
      decode_message_interaction_metadata,
    )(dyn),
    dynamic.optional_field("interaction", decode_message_interaction)(dyn),
    dynamic.optional_field("thread", decode_channel)(dyn),
    dynamic.optional_field("components", dynamic.list(dynamic.int))(dyn),
    dynamic.optional_field("sticker_items", dynamic.list(decode_sticker_item))(
      dyn,
    ),
    dynamic.optional_field("stickers", dynamic.list(decode_sticker))(dyn),
    dynamic.optional_field("position", dynamic.int)(dyn),
    dynamic.optional_field("role_subscription_data", decode_role_subscription)(
      dyn,
    ),
    dynamic.optional_field("resolved", decode_resolved)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12), Ok(a13), Ok(a14), Ok(a15), Ok(a16), Ok(a17), Ok(a18), Ok(
      a19,
    ), Ok(a20), Ok(a21), Ok(a22), Ok(a23), Ok(a24), Ok(a25), Ok(a26), Ok(a27), Ok(
      a28,
    ), Ok(a29), Ok(a30), Ok(a31), Ok(a32) ->
      Ok(discord.Message(
        a1,
        a2,
        a3,
        a4,
        a5,
        a6,
        a7,
        a8,
        a9,
        a10,
        a11,
        a12,
        a13,
        a14,
        a15,
        a16,
        a17,
        a18,
        a19,
        a20,
        a21,
        a22,
        a23,
        a24,
        a25,
        a26,
        a27,
        a28,
        a29,
        a30,
        a31,
        a32,
      ))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
          all_errors(a13),
          all_errors(a14),
          all_errors(a15),
          all_errors(a16),
          all_errors(a17),
          all_errors(a18),
          all_errors(a19),
          all_errors(a20),
          all_errors(a21),
          all_errors(a22),
          all_errors(a23),
          all_errors(a24),
          all_errors(a25),
          all_errors(a26),
          all_errors(a27),
          all_errors(a28),
          all_errors(a29),
          all_errors(a30),
          all_errors(a31),
          all_errors(a32),
        ]),
      )
  }
}

pub fn decode_resolved(
  dyn: dynamic.Dynamic,
) -> Result(discord.Resolved, dynamic.DecodeErrors) {
  case
    dynamic.optional_field("users", dynamic.dict(dynamic.string, decode_user))(
      dyn,
    ),
    dynamic.optional_field(
      "members",
      dynamic.dict(dynamic.string, decode_member),
    )(dyn),
    dynamic.optional_field("roles", dynamic.dict(dynamic.string, decode_role))(
      dyn,
    ),
    dynamic.optional_field(
      "channels",
      dynamic.dict(dynamic.string, decode_channel),
    )(dyn),
    dynamic.optional_field(
      "messages",
      dynamic.dict(dynamic.string, decode_message),
    )(dyn),
    dynamic.optional_field(
      "attachments",
      dynamic.dict(dynamic.string, decode_attachment),
    )(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6) ->
      Ok(discord.Resolved(a1, a2, a3, a4, a5, a6))
    a1, a2, a3, a4, a5, a6 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
        ]),
      )
  }
}

pub fn decode_channel(
  dyn: dynamic.Dynamic,
) -> Result(discord.Channel, dynamic.DecodeErrors) {
  case
    dynamic.field("id", dynamic.string)(dyn),
    dynamic.field("type", dynamic.int)(dyn),
    dynamic.optional_field("guild_id", dynamic.string)(dyn),
    dynamic.optional_field("position", dynamic.int)(dyn),
    dynamic.optional_field(
      "permission_overwrites",
      dynamic.list(decode_overwrite),
    )(dyn),
    dynamic.optional_field("name", dynamic.string)(dyn),
    dynamic.optional_field("topic", dynamic.string)(dyn),
    dynamic.optional_field("nsfw", dynamic.bool)(dyn),
    dynamic.optional_field("last_message_id", dynamic.string)(dyn),
    dynamic.optional_field("bitrate", dynamic.int)(dyn),
    dynamic.optional_field("user_limit", dynamic.int)(dyn),
    dynamic.optional_field("rate_limit_per_user", dynamic.int)(dyn),
    dynamic.optional_field("recipients", dynamic.list(decode_user))(dyn),
    dynamic.optional_field("icon", dynamic.string)(dyn),
    dynamic.optional_field("owner_id", dynamic.string)(dyn),
    dynamic.optional_field("application_id", dynamic.string)(dyn),
    dynamic.optional_field("managed", dynamic.bool)(dyn),
    dynamic.optional_field("parent_id", dynamic.string)(dyn),
    dynamic.optional_field("last_pin_timestamp", dynamic.string)(dyn),
    dynamic.optional_field("rtc_region", dynamic.string)(dyn),
    dynamic.optional_field("video_quality_mode", dynamic.int)(dyn),
    dynamic.optional_field("message_count", dynamic.int)(dyn),
    dynamic.optional_field("member_count", dynamic.int)(dyn),
    dynamic.optional_field("thread_metadata", decode_thread_metedata)(dyn),
    dynamic.optional_field("member", decode_member)(dyn),
    dynamic.optional_field("default_auto_archive_duration", dynamic.int)(dyn),
    dynamic.optional_field("permissions", dynamic.string)(dyn),
    dynamic.optional_field("flags", dynamic.int)(dyn),
    dynamic.optional_field("total_message_sent", dynamic.int)(dyn),
    dynamic.optional_field("available_tags", dynamic.list(decode_forum_tag))(
      dyn,
    ),
    dynamic.optional_field("applied_tags", dynamic.list(dynamic.string))(dyn),
    dynamic.optional_field("default_reaction_emoji", decode_default_reaction)(
      dyn,
    ),
    dynamic.optional_field("default_thread_rate_limit_per_user", dynamic.int)(
      dyn,
    ),
    dynamic.optional_field("default_sort_order", dynamic.string)(dyn),
    dynamic.optional_field("default_forum_layout", dynamic.int)(dyn)
  {
    Ok(a1), Ok(a2), Ok(a3), Ok(a4), Ok(a5), Ok(a6), Ok(a7), Ok(a8), Ok(a9), Ok(
      a10,
    ), Ok(a11), Ok(a12), Ok(a13), Ok(a14), Ok(a15), Ok(a16), Ok(a17), Ok(a18), Ok(
      a19,
    ), Ok(a20), Ok(a21), Ok(a22), Ok(a23), Ok(a24), Ok(a25), Ok(a26), Ok(a27), Ok(
      a28,
    ), Ok(a29), Ok(a30), Ok(a31), Ok(a32), Ok(a33), Ok(a34), Ok(a35) ->
      Ok(discord.Channel(
        a1,
        a2,
        a3,
        a4,
        a5,
        a6,
        a7,
        a8,
        a9,
        a10,
        a11,
        a12,
        a13,
        a14,
        a15,
        a16,
        a17,
        a18,
        a19,
        a20,
        a21,
        a22,
        a23,
        a24,
        a25,
        a26,
        a27,
        a28,
        a29,
        a30,
        a31,
        a32,
        a33,
        a34,
        a35,
      ))
    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35 ->
      Error(
        list.concat([
          all_errors(a1),
          all_errors(a2),
          all_errors(a3),
          all_errors(a4),
          all_errors(a5),
          all_errors(a6),
          all_errors(a7),
          all_errors(a8),
          all_errors(a9),
          all_errors(a10),
          all_errors(a11),
          all_errors(a12),
          all_errors(a13),
          all_errors(a14),
          all_errors(a15),
          all_errors(a16),
          all_errors(a17),
          all_errors(a18),
          all_errors(a19),
          all_errors(a20),
          all_errors(a21),
          all_errors(a22),
          all_errors(a23),
          all_errors(a24),
          all_errors(a25),
          all_errors(a26),
          all_errors(a27),
          all_errors(a28),
          all_errors(a29),
          all_errors(a30),
          all_errors(a31),
          all_errors(a32),
          all_errors(a33),
          all_errors(a34),
          all_errors(a35),
        ]),
      )
  }
}
