import gleam/dynamic.{type Dynamic, type DecodeErrors}

type MessageDecoder(message) =
  fn(Dynamic) -> Result(message, DecodeErrors)

fn message(
  constructor: fn(
    id,
    channel_id,
    author,
    content,
    tts,
    mention_everyone,
    pinned,
    message_type,
  ) ->
    discord.Message,
  id: MessageDecoder(id),
  channel_id: MessageDecoder(channel_id),
  author: MessageDecoder(author),
  content: MessageDecoder(content),
  tts: MessageDecoder(tts),
  mention_everyone: MessageDecoder(mention_everyone),
  pinned: MessageDecoder(pinned),
  message_type: MessageDecoder(message_type),
) -> MessageDecoder(discord.Message) {
  fn(message: Dynamic) {
    case
      id(message),
      channel_id(message),
      author(message),
      content(message),
      tts(message),
      mention_everyone(message),
      pinned(message),
      message_type(message)
    {
      Ok(a), Ok(b), Ok(c), Ok(d), Ok(e), Ok(f), Ok(g), Ok(h) ->
        Ok(constructor(a, b, c, d, e, f, g, h))
      a, b, c, d, e, f, g, h ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
          ]),
        )
    }
  }
}

pub fn message_decoder(dyn: Dynamic) -> Result(discord.Message, DecodeErrors) {
  message(
    discord.Message,
    dynamic.field("id", dynamic.string),
    dynamic.field("channel_id", dynamic.string),
    dynamic.field("author", user_decoder()),
    dynamic.field("content", dynamic.string),
    dynamic.field("tts", dynamic.bool),
    dynamic.field("mention_everyone", dynamic.bool),
    dynamic.field("pinned", dynamic.bool),
    dynamic.field("type", dynamic.int),
  )(dyn)
}