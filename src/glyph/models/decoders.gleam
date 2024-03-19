//// This contains all decoders needed to parse responses into models.
//// Adapted from Gleam's stdlib dynamic decoders.
//// 
//// Abandon all hope, ye who enter.

import gleam/dynamic.{type DecodeErrors, type Dynamic}
import gleam/list
import glyph/models/discord

type ApplicationDecoder(app) =
  fn(Dynamic) -> Result(app, DecodeErrors)

fn application(
  constructor: fn(
    id,
    name,
    icon,
    description,
    rpc_origins,
    bot_public,
    bot_require_code_grant,
    bot,
    terms_of_service_url,
    privacy_policy_url,
    owner,
    summary,
    verify_key,
    team,
    guild_id,
    primary_sku_id,
    slug,
    cover_image,
    flags,
    approximate_guild_count,
    redirect_uris,
    interactions_endpoint_url,
    role_connections_verification_url,
    tags,
    install_params,
    custom_install_url,
  ) ->
    discord.Application,
  id: ApplicationDecoder(id),
  name: ApplicationDecoder(name),
  icon: ApplicationDecoder(icon),
  description: ApplicationDecoder(description),
  rpc_origins: ApplicationDecoder(rpc_origins),
  bot_public: ApplicationDecoder(bot_public),
  bot_require_code_grant: ApplicationDecoder(bot_require_code_grant),
  bot: ApplicationDecoder(bot),
  terms_of_service_url: ApplicationDecoder(terms_of_service_url),
  privacy_policy_url: ApplicationDecoder(privacy_policy_url),
  owner: ApplicationDecoder(owner),
  summary: ApplicationDecoder(summary),
  verify_key: ApplicationDecoder(verify_key),
  team: ApplicationDecoder(team),
  guild_id: ApplicationDecoder(guild_id),
  primary_sku_id: ApplicationDecoder(primary_sku_id),
  slug: ApplicationDecoder(slug),
  cover_image: ApplicationDecoder(cover_image),
  flags: ApplicationDecoder(flags),
  approximate_guild_count: ApplicationDecoder(approximate_guild_count),
  redirect_uris: ApplicationDecoder(redirect_uris),
  interactions_endpoint_url: ApplicationDecoder(interactions_endpoint_url),
  role_connections_verification_url: ApplicationDecoder(
    role_connections_verification_url,
  ),
  tags: ApplicationDecoder(tags),
  install_params: ApplicationDecoder(install_params),
  custom_install_url: ApplicationDecoder(custom_install_url),
) -> ApplicationDecoder(discord.Application) {
  fn(app: Dynamic) {
    case
      id(app),
      name(app),
      icon(app),
      description(app),
      rpc_origins(app),
      bot_public(app),
      bot_require_code_grant(app),
      bot(app),
      terms_of_service_url(app),
      privacy_policy_url(app),
      owner(app),
      summary(app),
      verify_key(app),
      team(app),
      guild_id(app),
      primary_sku_id(app),
      slug(app),
      cover_image(app),
      flags(app),
      approximate_guild_count(app),
      redirect_uris(app),
      interactions_endpoint_url(app),
      role_connections_verification_url(app),
      tags(app),
      install_params(app),
      custom_install_url(app)
    {
      Ok(a), Ok(b), Ok(c), Ok(d), Ok(e), Ok(f), Ok(g), Ok(h), Ok(i), Ok(j), Ok(
        k,
      ), Ok(l), Ok(m), Ok(n), Ok(o), Ok(p), Ok(q), Ok(r), Ok(s), Ok(t), Ok(u), Ok(
        v,
      ), Ok(w), Ok(x), Ok(y), Ok(z) ->
        Ok(constructor(
          a,
          b,
          c,
          d,
          e,
          f,
          g,
          h,
          i,
          j,
          k,
          l,
          m,
          n,
          o,
          p,
          q,
          r,
          s,
          t,
          u,
          v,
          w,
          x,
          y,
          z,
        ))
      a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z ->
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
            all_errors(i),
            all_errors(j),
            all_errors(k),
            all_errors(l),
            all_errors(m),
            all_errors(n),
            all_errors(o),
            all_errors(p),
            all_errors(q),
            all_errors(r),
            all_errors(s),
            all_errors(t),
            all_errors(u),
            all_errors(v),
            all_errors(w),
            all_errors(x),
            all_errors(y),
            all_errors(z),
          ]),
        )
    }
  }
}

pub fn application_decoder() -> ApplicationDecoder(discord.Application) {
  application(
    discord.Application,
    dynamic.field("id", of: dynamic.string),
    dynamic.field("name", of: dynamic.string),
    dynamic.optional_field("icon", of: dynamic.string),
    dynamic.field("description", of: dynamic.string),
    dynamic.optional_field("rpc_origins", of: dynamic.list(dynamic.string)),
    dynamic.field("bot_public", of: dynamic.bool),
    dynamic.field("bot_require_code_grant", of: dynamic.bool),
    dynamic.optional_field("bot", of: user_decoder()),
    dynamic.optional_field("terms_of_service_url", of: dynamic.string),
    dynamic.optional_field("privacy_policy_url", of: dynamic.string),
    dynamic.optional_field("owner", of: user_decoder()),
    dynamic.optional_field("summary", of: dynamic.string),
    dynamic.field("verify_key", of: dynamic.string),
    dynamic.optional_field("team", of: team_decoder()),
    dynamic.optional_field("guild_id", of: dynamic.string),
    dynamic.optional_field("primary_sku_id", of: dynamic.string),
    dynamic.optional_field("slug", of: dynamic.string),
    dynamic.optional_field("cover_image", of: dynamic.string),
    dynamic.optional_field("flags", of: dynamic.int),
    dynamic.optional_field("approximate_guild_count", of: dynamic.int),
    dynamic.optional_field("redirect_uris", of: dynamic.list(dynamic.string)),
    dynamic.optional_field("interactions_endpoint_url", of: dynamic.string),
    dynamic.optional_field(
      "role_connections_verification_url",
      of: dynamic.string,
    ),
    dynamic.optional_field("tags", of: dynamic.list(dynamic.string)),
    dynamic.optional_field("install_params", of: install_params_decoder()),
    dynamic.optional_field("custom_install_url", of: dynamic.string),
  )
}

type UserDecoder(user) =
  fn(Dynamic) -> Result(user, DecodeErrors)

fn user(
  constructor: fn(
    id,
    username,
    discriminator,
    global_name,
    avatar,
    bot,
    system,
    mfa_enabled,
    banner,
    accent_color,
    locale,
    email,
    flags,
    premium_type,
    public_flags,
    avatar_decoration,
  ) ->
    discord.User,
  id: UserDecoder(id),
  username: UserDecoder(username),
  discriminator: UserDecoder(discriminator),
  global_name: UserDecoder(global_name),
  avatar: UserDecoder(avatar),
  bot: UserDecoder(bot),
  system: UserDecoder(system),
  mfa_enabled: UserDecoder(mfa_enabled),
  banner: UserDecoder(banner),
  accent_color: UserDecoder(accent_color),
  locale: UserDecoder(locale),
  email: UserDecoder(email),
  flags: UserDecoder(flags),
  premium_type: UserDecoder(premium_type),
  public_flags: UserDecoder(public_flags),
  avatar_decoration: UserDecoder(avatar_decoration),
) -> UserDecoder(discord.User) {
  fn(user: Dynamic) {
    case
      id(user),
      username(user),
      discriminator(user),
      global_name(user),
      avatar(user),
      bot(user),
      system(user),
      mfa_enabled(user),
      banner(user),
      accent_color(user),
      locale(user),
      email(user),
      flags(user),
      premium_type(user),
      public_flags(user),
      avatar_decoration(user)
    {
      Ok(a), Ok(b), Ok(c), Ok(d), Ok(e), Ok(f), Ok(g), Ok(h), Ok(i), Ok(j), Ok(
        k,
      ), Ok(l), Ok(m), Ok(n), Ok(o), Ok(p) ->
        Ok(constructor(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p))
      a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p ->
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
            all_errors(i),
            all_errors(j),
            all_errors(k),
            all_errors(l),
            all_errors(m),
            all_errors(n),
            all_errors(o),
            all_errors(p),
          ]),
        )
    }
  }
}

pub fn user_decoder() -> UserDecoder(discord.User) {
  user(
    discord.User,
    dynamic.field("id", of: dynamic.string),
    dynamic.field("username", of: dynamic.string),
    dynamic.field("discriminator", of: dynamic.string),
    dynamic.optional_field("global_name", of: dynamic.string),
    dynamic.optional_field("avatar", of: dynamic.string),
    dynamic.optional_field("bot", of: dynamic.bool),
    dynamic.optional_field("system", of: dynamic.bool),
    dynamic.optional_field("mfa_enabled", of: dynamic.bool),
    dynamic.optional_field("banner", of: dynamic.string),
    dynamic.optional_field("accent_color", of: dynamic.int),
    dynamic.optional_field("locale", of: dynamic.string),
    dynamic.optional_field("email", of: dynamic.string),
    dynamic.optional_field("flags", of: dynamic.int),
    dynamic.optional_field("premium_type", of: dynamic.int),
    dynamic.optional_field("public_flags", of: dynamic.int),
    dynamic.optional_field("avatar_decoration", of: dynamic.string),
  )
}

type TeamDecoder(team) =
  fn(Dynamic) -> Result(team, DecodeErrors)

fn team(
  constructor: fn(id, icon, members, name, owner_user_id) -> discord.Team,
  id: TeamDecoder(id),
  icon: TeamDecoder(icon),
  members: TeamDecoder(members),
  name: TeamDecoder(name),
  owner_user_id: TeamDecoder(owner_user_id),
) -> TeamDecoder(discord.Team) {
  fn(team: Dynamic) {
    case id(team), icon(team), members(team), name(team), owner_user_id(team) {
      Ok(a), Ok(b), Ok(c), Ok(d), Ok(e) -> Ok(constructor(a, b, c, d, e))
      a, b, c, d, e ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
          ]),
        )
    }
  }
}

pub fn team_decoder() -> TeamDecoder(discord.Team) {
  team(
    discord.Team,
    dynamic.field("id", of: dynamic.string),
    dynamic.optional_field("icon", of: dynamic.string),
    dynamic.field("members", of: dynamic.list(member_decoder())),
    dynamic.field("name", of: dynamic.string),
    dynamic.field("owner_user_id", of: dynamic.string),
  )
}

type MemberDecoder(member) =
  fn(Dynamic) -> Result(member, DecodeErrors)

fn member(
  constructor: fn(membership_state, team_id, user, role) -> discord.Member,
  membership_state: MemberDecoder(membership_state),
  team_id: MemberDecoder(team_id),
  user: MemberDecoder(user),
  role: MemberDecoder(role),
) -> MemberDecoder(discord.Member) {
  fn(member: Dynamic) {
    case membership_state(member), team_id(member), user(member), role(member) {
      Ok(a), Ok(b), Ok(c), Ok(d) -> Ok(constructor(a, b, c, d))
      a, b, c, d ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
          ]),
        )
    }
  }
}

pub fn member_decoder() -> MemberDecoder(discord.Member) {
  member(
    discord.Member,
    dynamic.field("membership_state", of: dynamic.int),
    dynamic.field("team_id", of: dynamic.string),
    dynamic.field("user", of: user_decoder()),
    dynamic.field("role", of: dynamic.string),
  )
}

type InstallParamsDecoder(install_params) =
  fn(Dynamic) -> Result(install_params, DecodeErrors)

fn install_params(
  constructor: fn(scopes, permissions) -> discord.InstallParams,
  scopes: InstallParamsDecoder(scopes),
  permissions: InstallParamsDecoder(permissions),
) -> InstallParamsDecoder(discord.InstallParams) {
  fn(install_params: Dynamic) {
    case scopes(install_params), permissions(install_params) {
      Ok(a), Ok(b) -> Ok(constructor(a, b))
      a, b -> Error(list.concat([all_errors(a), all_errors(b)]))
    }
  }
}

pub fn install_params_decoder() -> InstallParamsDecoder(discord.InstallParams) {
  install_params(
    discord.InstallParams,
    dynamic.field("scopes", dynamic.list(dynamic.string)),
    dynamic.field("permissions", dynamic.string),
  )
}

type GetGatewayBotDecoder(gateway_bot) =
  fn(Dynamic) -> Result(gateway_bot, DecodeErrors)

fn get_gateway_bot(
  constructor: fn(url, shards, session_start_limit) -> discord.GetGatewayBot,
  url: GetGatewayBotDecoder(url),
  shards: GetGatewayBotDecoder(shards),
  session_start_limit: GetGatewayBotDecoder(session_start_limit),
) -> GetGatewayBotDecoder(discord.GetGatewayBot) {
  fn(gateway_bot: Dynamic) {
    case
      url(gateway_bot),
      shards(gateway_bot),
      session_start_limit(gateway_bot)
    {
      Ok(a), Ok(b), Ok(c) -> Ok(constructor(a, b, c))
      a, b, c ->
        Error(list.concat([all_errors(a), all_errors(b), all_errors(c)]))
    }
  }
}

pub fn get_gateway_bot_decoder() -> GetGatewayBotDecoder(discord.GetGatewayBot) {
  get_gateway_bot(
    discord.GetGatewayBot,
    dynamic.field("url", dynamic.string),
    dynamic.field("shards", dynamic.int),
    dynamic.field("session_start_limit", session_start_limit_decoder()),
  )
}

type SessionStartLimitDecoder(session_start_limit) =
  fn(Dynamic) -> Result(session_start_limit, DecodeErrors)

fn session_start_limit(
  constructor: fn(total, remaining, reset_after, max_concurrency) ->
    discord.SessionStartLimit,
  total: SessionStartLimitDecoder(total),
  remaining: SessionStartLimitDecoder(remaining),
  reset_after: SessionStartLimitDecoder(reset_after),
  max_concurrency: SessionStartLimitDecoder(max_concurrency),
) -> SessionStartLimitDecoder(discord.SessionStartLimit) {
  fn(session_start_limit: Dynamic) {
    case
      total(session_start_limit),
      remaining(session_start_limit),
      reset_after(session_start_limit),
      max_concurrency(session_start_limit)
    {
      Ok(a), Ok(b), Ok(c), Ok(d) -> Ok(constructor(a, b, c, d))
      a, b, c, d ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
          ]),
        )
    }
  }
}

pub fn session_start_limit_decoder() -> SessionStartLimitDecoder(
  discord.SessionStartLimit,
) {
  session_start_limit(
    discord.SessionStartLimit,
    dynamic.field("total", dynamic.int),
    dynamic.field("remaining", dynamic.int),
    dynamic.field("reset_after", dynamic.int),
    dynamic.field("max_concurrency", dynamic.int),
  )
}

fn all_errors(result: Result(a, DecodeErrors)) -> DecodeErrors {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}
