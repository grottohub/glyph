//// This contains the builder functions for constructing an Embed
//// 
//// ## Example
//// 
//// ```gleam
//// embed.new()
//// |> embed.title("Example embed")
//// |> embed.description("Example description")
//// ```

import gleam/list
import gleam/option.{type Option, None, Some}
import glyph/models/discord

/// Construct a new, empty Embed
pub fn new() -> discord.Embed {
  discord.Embed(
    title: None,
    description: None,
    url: None,
    timestamp: None,
    color: None,
    footer: None,
    image: None,
    thumbnail: None,
    video: None,
    provider: None,
    author: None,
    fields: None,
  )
}

/// Set the title of the embed
pub fn title(e: discord.Embed, title: String) -> discord.Embed {
  discord.Embed(..e, title: Some(title))
}

/// Set the description of the embed
pub fn description(e: discord.Embed, description: String) -> discord.Embed {
  discord.Embed(..e, description: Some(description))
}

/// Set the source URL of the embed
pub fn url(e: discord.Embed, url: String) -> discord.Embed {
  discord.Embed(..e, url: Some(url))
}

/// Set the embed color to one of the available options
pub fn color(e: discord.Embed, color: EmbedColor) -> discord.Embed {
  discord.Embed(..e, color: Some(color_to_int(color)))
}

/// Set the source URL for an image
pub fn image(e: discord.Embed, image_url: String) -> discord.Embed {
  let image = option.unwrap(e.image, or: empty_image())
  let updated_image = discord.EmbedImage(..image, url: image_url)

  discord.Embed(..e, image: Some(updated_image))
}

/// Set the height of the embedded image
pub fn image_height(e: discord.Embed, height: Int) -> discord.Embed {
  let image = option.unwrap(e.image, or: empty_image())
  let updated_image = discord.EmbedImage(..image, height: Some(height))

  discord.Embed(..e, image: Some(updated_image))
}

/// Set the width of the embedded image
pub fn image_width(e: discord.Embed, width: Int) -> discord.Embed {
  let image = option.unwrap(e.image, or: empty_image())
  let updated_image = discord.EmbedImage(..image, width: Some(width))

  discord.Embed(..e, image: Some(updated_image))
}

/// Set the source URL for a thumbnail
pub fn thumbnail(e: discord.Embed, thumbnail_url: String) -> discord.Embed {
  let thumbnail = option.unwrap(e.thumbnail, or: empty_thumbnail())
  let updated_thumbnail =
    discord.EmbedThumbnail(..thumbnail, url: thumbnail_url)

  discord.Embed(..e, thumbnail: Some(updated_thumbnail))
}

/// Set the height of the thumbnail image
pub fn thumbnail_height(e: discord.Embed, height: Int) -> discord.Embed {
  let thumbnail = option.unwrap(e.thumbnail, or: empty_thumbnail())
  let updated_thumbnail =
    discord.EmbedThumbnail(..thumbnail, height: Some(height))

  discord.Embed(..e, thumbnail: Some(updated_thumbnail))
}

/// Set the width of the thumbnail image
pub fn thumbnail_width(e: discord.Embed, width: Int) -> discord.Embed {
  let thumbnail = option.unwrap(e.thumbnail, or: empty_thumbnail())
  let updated_thumbnail =
    discord.EmbedThumbnail(..thumbnail, width: Some(width))

  discord.Embed(..e, thumbnail: Some(updated_thumbnail))
}

/// Set the source URL for a video
pub fn video(e: discord.Embed, video_url: String) -> discord.Embed {
  let video = option.unwrap(e.video, or: empty_video())
  let updated_video = discord.EmbedVideo(..video, url: Some(video_url))

  discord.Embed(..e, video: Some(updated_video))
}

/// Set the height of the embedded video
pub fn video_height(e: discord.Embed, height: Int) -> discord.Embed {
  let video = option.unwrap(e.video, or: empty_video())
  let updated_video = discord.EmbedVideo(..video, height: Some(height))

  discord.Embed(..e, video: Some(updated_video))
}

/// Set the width of the embedded video
pub fn video_width(e: discord.Embed, width: Int) -> discord.Embed {
  let video = option.unwrap(e.video, or: empty_video())
  let updated_video = discord.EmbedVideo(..video, width: Some(width))

  discord.Embed(..e, video: Some(updated_video))
}

/// Set a name and URL for a provider (e.g. Twitch and https://twitch.tv)
pub fn provider(
  e: discord.Embed,
  name: Option(String),
  url: Option(String),
) -> discord.Embed {
  discord.Embed(
    ..e,
    provider: Some(discord.EmbedProvider(name: name, url: url)),
  )
}

/// Set a name for an author
pub fn author(e: discord.Embed, name: String) -> discord.Embed {
  let author = option.unwrap(e.author, or: empty_author())
  let updated_author = discord.EmbedAuthor(..author, name: name)

  discord.Embed(..e, author: Some(updated_author))
}

/// Set a URL for an author
pub fn author_url(e: discord.Embed, url: String) -> discord.Embed {
  let author = option.unwrap(e.author, or: empty_author())
  let updated_author = discord.EmbedAuthor(..author, url: Some(url))

  discord.Embed(..e, author: Some(updated_author))
}

/// Set an icon URL for an author
pub fn author_icon(e: discord.Embed, icon_url: String) -> discord.Embed {
  let author = option.unwrap(e.author, or: empty_author())
  let updated_author = discord.EmbedAuthor(..author, icon_url: Some(icon_url))

  discord.Embed(..e, author: Some(updated_author))
}

/// Add a new field to the embed
pub fn field(
  e: discord.Embed,
  name: String,
  value: String,
  inline: Bool,
) -> discord.Embed {
  let fields = option.unwrap(e.fields, or: [])
  let new_field =
    discord.EmbedField(name: name, value: value, inline: Some(inline))

  discord.Embed(..e, fields: Some(list.append(fields, [new_field])))
}

/// Set the text for the embed's footer
pub fn footer_text(e: discord.Embed, text: String) -> discord.Embed {
  let footer = option.unwrap(e.footer, or: empty_footer())
  let updated_footer = discord.EmbedFooter(..footer, text: text)

  discord.Embed(..e, footer: Some(updated_footer))
}

/// Set an icon URL for the embed's footer
pub fn footer_icon_url(e: discord.Embed, icon_url: String) -> discord.Embed {
  let footer = option.unwrap(e.footer, or: empty_footer())
  let updated_footer = discord.EmbedFooter(..footer, icon_url: Some(icon_url))

  discord.Embed(..e, footer: Some(updated_footer))
}

fn empty_footer() -> discord.EmbedFooter {
  discord.EmbedFooter(text: "", icon_url: None, proxy_icon_url: None)
}

fn empty_image() -> discord.EmbedImage {
  discord.EmbedImage(url: "", proxy_url: None, height: None, width: None)
}

fn empty_thumbnail() -> discord.EmbedThumbnail {
  discord.EmbedThumbnail(url: "", proxy_url: None, height: None, width: None)
}

fn empty_video() -> discord.EmbedVideo {
  discord.EmbedVideo(url: None, proxy_url: None, height: None, width: None)
}

fn empty_author() -> discord.EmbedAuthor {
  discord.EmbedAuthor(name: "", url: None, icon_url: None, proxy_icon_url: None)
}

/// These are the colors of the official Discord palette
pub type EmbedColor {
  White
  Greyple
  Black
  DarkButNotBlack
  NotQuiteBlack
  Blurple
  Green
  Yellow
  Fuschia
  Red
}

fn color_to_int(c: EmbedColor) -> Int {
  case c {
    White -> 16_777_215
    Greyple -> 10_070_709
    Black -> 23_033_786
    DarkButNotBlack -> 2_895_667
    NotQuiteBlack -> 2_303_786
    Blurple -> 5_793_266
    Green -> 5_763_719
    Yellow -> 16_705_372
    Fuschia -> 15_418_782
    Red -> 15_548_997
  }
}
