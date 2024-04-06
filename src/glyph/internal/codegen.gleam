import glyph_codegen/codegen
import gleam/dict

pub fn main() {
    codegen.generate(
        codegen.Args(
             types: [
                "User",
                "ReadyApplication",
                "InstallParams",
                "MessagePayload",
                "Team",
                "Member",
                "SessionStartLimit",
                "GetGatewayBot",
                "GatewayEvent",
                "HelloEvent",
                "ReadyEvent",
                "RoleTag",
                "Role",
                "ChannelMention",
                "Attachment",
                "Embed",
                "Emoji",
                "MessageReference",
                "MessageInteractionMetadata",
                "GuildMember",
                "MessageInteraction",
                "Overwrite",
                "ThreadMetedata",
                "ForumTag",
                "DefaultReaction",
                "StickerItem",
                "Sticker",
                "RoleSubscription",
                "Reaction",
                "Application",
                "Message",
                "Resolved",
                "Channel",
             ],
            out_file: "./src/glyph/internal/decoders.gleam",
            import_module: "glyph/models/discord",
            rename: dict.from_list([
                #("kind", "type")
            ]),
        )
    )
}