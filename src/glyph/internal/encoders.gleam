//// This contains all encoders needed to convert Discord payloads into JSON.

import gleam/json
import gleam/list
import gleam/option
import glyph/models/discord

pub fn message_to_json(message: discord.MessagePayload) -> String {
  json.object([
    #("content", json.nullable(message.content, json.string)),
    #("tts", json.nullable(message.tts, json.bool)),
    #("embeds", json.array(option.unwrap(message.embeds, []), embed_to_json)),
    #(
      "allowed_mentions",
      json.nullable(message.allowed_mentions, allowed_mentions_to_json),
    ),
    #(
      "message_reference",
      json.nullable(message.message_reference, message_reference_to_json),
    ),
    #(
      "sticker_ids",
      json.array(option.unwrap(message.sticker_ids, []), json.string),
    ),
    #("flags", json.nullable(message.flags, json.int)),
    #("nonce", json.nullable(message.nonce, json.string)),
    #("enforce_nonce", json.nullable(message.enforce_nonce, json.bool)),
  ])
  |> json.to_string
}

fn message_reference_to_json(ref: discord.MessageReference) -> json.Json {
  json.object([
    #("message_id", json.nullable(ref.message_id, json.string)),
    #("channel_id", json.nullable(ref.channel_id, json.string)),
    #("guild_id", json.nullable(ref.guild_id, json.string)),
    #("fail_if_not_exists", json.nullable(ref.fail_if_not_exists, json.bool)),
  ])
}

fn allowed_mentions_to_json(ment: discord.AllowedMentions) -> json.Json {
  json.object([
    #(
      "parse",
      json.array(
        list.map(ment.parse, discord.mention_type_to_string),
        json.string,
      ),
    ),
    #("roles", json.array(ment.roles, json.string)),
    #("users", json.array(ment.users, json.string)),
    #("replied_user", json.bool(ment.replied_user)),
  ])
}

fn embed_to_json(embed: discord.Embed) -> json.Json {
  json.object([
    #("title", json.nullable(embed.title, json.string)),
    #("description", json.nullable(embed.description, json.string)),
    #("url", json.nullable(embed.url, json.string)),
    #("timestamp", json.nullable(embed.timestamp, json.string)),
    #("color", json.nullable(embed.color, json.int)),
    #("footer", json.nullable(embed.footer, embed_footer_to_json)),
    #("image", json.nullable(embed.image, embed_img_to_json)),
    #("thumbnail", json.nullable(embed.thumbnail, embed_thumbnail_to_json)),
    #("video", json.nullable(embed.video, embed_video_to_json)),
    #("provider", json.nullable(embed.provider, embed_provider_to_json)),
    #("author", json.nullable(embed.author, embed_author_to_json)),
    #(
      "fields",
      json.array(option.unwrap(embed.fields, []), embed_field_to_json),
    ),
  ])
}

fn embed_footer_to_json(footer: discord.EmbedFooter) -> json.Json {
  json.object([
    #("text", json.string(footer.text)),
    #("icon_url", json.nullable(footer.icon_url, json.string)),
    #("proxy_icon_url", json.nullable(footer.proxy_icon_url, json.string)),
  ])
}

fn embed_img_to_json(img: discord.EmbedImage) -> json.Json {
  json.object([
    #("url", json.string(img.url)),
    #("proxy_url", json.nullable(img.proxy_url, json.string)),
    #("height", json.nullable(img.height, json.int)),
    #("width", json.nullable(img.width, json.int)),
  ])
}

fn embed_thumbnail_to_json(img: discord.EmbedThumbnail) -> json.Json {
  json.object([
    #("url", json.string(img.url)),
    #("proxy_url", json.nullable(img.proxy_url, json.string)),
    #("height", json.nullable(img.height, json.int)),
    #("width", json.nullable(img.width, json.int)),
  ])
}

fn embed_video_to_json(vid: discord.EmbedVideo) -> json.Json {
  json.object([
    #("url", json.nullable(vid.url, json.string)),
    #("proxy_url", json.nullable(vid.proxy_url, json.string)),
    #("height", json.nullable(vid.height, json.int)),
    #("width", json.nullable(vid.width, json.int)),
  ])
}

fn embed_provider_to_json(prov: discord.EmbedProvider) -> json.Json {
  json.object([
    #("name", json.nullable(prov.name, json.string)),
    #("url", json.nullable(prov.url, json.string)),
  ])
}

fn embed_author_to_json(author: discord.EmbedAuthor) -> json.Json {
  json.object([
    #("name", json.string(author.name)),
    #("url", json.nullable(author.url, json.string)),
    #("icon_url", json.nullable(author.icon_url, json.string)),
    #("proxy_icon_url", json.nullable(author.proxy_icon_url, json.string)),
  ])
}

fn embed_field_to_json(field: discord.EmbedField) -> json.Json {
  json.object([
    #("name", json.string(field.name)),
    #("value", json.string(field.value)),
    #("inline", json.nullable(field.inline, json.bool)),
  ])
}
