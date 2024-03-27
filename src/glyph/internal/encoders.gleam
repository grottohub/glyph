//// This contains all encoders needed to convert Discord payloads into JSON.

import gleam/json
import glyph/models/discord

pub fn message_to_json(message: discord.MessagePayload) -> String {
  json.object([#("content", json.string(message.content))])
  |> json.to_string
}
