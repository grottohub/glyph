//// Module for interacting with ETS to store session data

import carpenter/table
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/result

/// Build a new ETS table
pub fn initialize() -> table.Set(String, String) {
  table.build("glyph_session")
  |> table.privacy(table.Private)
  |> table.write_concurrency(table.AutoWriteConcurrency)
  |> table.read_concurrency(False)
  |> table.decentralized_counters(True)
  |> table.compression(False)
  |> table.set
}

/// Generic retrieval with default unwrapping
fn get(cache: table.Set(String, String), key: String, default: String) -> String {
  cache
  |> table.lookup(key)
  |> option.unwrap(or: [#("", default)])
  |> list.first
  |> result.unwrap(or: #("", default))
  |> pair.second
}

/// Whether or not the bot should attempt to resume a session
pub fn should_resume(cache: table.Set(String, String), default: Bool) -> Bool {
  case get(cache, "should_resume", "not found") {
    "true" -> True
    "false" -> False
    _ -> default
  }
}

/// The URL the bot should use when resuming a session
pub fn resume_gateway_url(
  cache: table.Set(String, String),
  default: String,
) -> String {
  get(cache, "resume_gateway_url", default)
}

/// The most recent sequence received from the gateway
pub fn seq(cache: table.Set(String, String), default: Int) -> Int {
  get(cache, "seq", "not found")
  |> int.parse
  |> result.unwrap(or: default)
}

/// The ID of the session that the bot should resume
pub fn session_id(cache: table.Set(String, String), default: String) -> String {
  get(cache, "session_id", default)
}
