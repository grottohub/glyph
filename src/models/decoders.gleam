//// This contains all decoders needed to parse responses into models.
//// Adapted from Gleam's stdlib dynamic decoders.
//// 
//// Abandon all hope, ye who enter.

import gleam/dynamic.{type DecodeErrors, type Dynamic}
import gleam/list
import models/api

pub type ApplicationDecoder(app) =
  fn(Dynamic) -> Result(app, DecodeErrors)

pub fn application(
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
    api.Application,
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
) -> ApplicationDecoder(api.Application) {
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

pub type UserDecoder(user) =
  fn(Dynamic) -> Result(user, DecodeErrors)

pub fn user(
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
    api.User,
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
) -> UserDecoder(api.User) {
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

pub type TeamDecoder(team) =
  fn(Dynamic) -> Result(team, DecodeErrors)

pub fn team(
  constructor: fn(id, icon, members, name, owner_user_id) -> api.Team,
  id: TeamDecoder(id),
  icon: TeamDecoder(icon),
  members: TeamDecoder(members),
  name: TeamDecoder(name),
  owner_user_id: TeamDecoder(owner_user_id),
) -> TeamDecoder(api.Team) {
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

pub type MemberDecoder(member) =
  fn(Dynamic) -> Result(member, DecodeErrors)

pub fn member(
  constructor: fn(membership_state, team_id, user, role) -> api.Member,
  membership_state: MemberDecoder(membership_state),
  team_id: MemberDecoder(team_id),
  user: MemberDecoder(user),
  role: MemberDecoder(role),
) -> MemberDecoder(api.Member) {
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

pub type InstallParamsDecoder(install_params) =
  fn(Dynamic) -> Result(install_params, DecodeErrors)

pub fn install_params(
  constructor: fn(scopes, permissions) -> api.InstallParams,
  scopes: InstallParamsDecoder(scopes),
  permissions: InstallParamsDecoder(permissions),
) -> InstallParamsDecoder(api.InstallParams) {
  fn(install_params: Dynamic) {
    case scopes(install_params), permissions(install_params) {
      Ok(a), Ok(b) -> Ok(constructor(a, b))
      a, b -> Error(list.concat([all_errors(a), all_errors(b)]))
    }
  }
}

fn all_errors(result: Result(a, DecodeErrors)) -> DecodeErrors {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}
