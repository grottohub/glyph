/// Module for interacting with ETS to store session data
import carpenter/builder
import carpenter/config/privacy
import carpenter/table/set

pub fn initialize() -> set.Set(String, String) {
  let c =
    builder.new("glyph_session")
    |> builder.privacy(privacy.Private)
    |> builder.set()

  c
  |> set.insert("resume_gateway_url", "")
  |> set.insert("seq", "")
  |> set.insert("session_id", "")
}
