defmodule Glimesh.Costreams.CostreamLookups do
@moduledoc false

import Ecto.Query

alias Glimesh.Accounts.User
alias Glimesh.Streams.{Channel, Costream, CostreamInvites}
alias Glimesh.Repo

  def get_active_hosted_costreams(%Channel{} = channel) do
    from(c in Costream,
    where: c.host_id == ^channel.id,
    where: c.active == true,
    order_by: [asc: c.status, desc: c.updated_at])
    |> Repo.replica().all()
  end

  def get_active_invited_costreams(%Channel{} = channel) do
    from(ci in CostreamInvites,
      join: c in Costream,
      on: ci.costream_id == c.id,
      join: host_channel in Channel,
      on: c.host_id == host_channel.id,
      join: host_user in User,
      on: host_channel.user_id == host_user.id,
      where: c.active == true,
      where: ci.channel_id == ^channel.id,
      where: ci.active == true,
      where: ci.status != :expired,
      where: host_channel.inaccessible == false,
      where: host_user.can_stream == true,
      where: host_user.is_banned == false,
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", ^channel.user_id, c.host_channel_id),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", c.host_channel_id, ^channel.user_id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ^channel.id, c.host_channel_id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", c.host_channel_id, ^channel.id),
      order_by: [asc: ci.status, desc: ci.updated_at],
      preload: [costream: c],
      preload: [channel: [:user]])
    |> Repo.replica().all()
  end

  def search_for_possible_costreamers(%Costream{} = costream, display_name, %User{} = host) do
    if display_name != nil and String.length(display_name) < 25 do
      search_term = Regex.replace(~r/(\\\\|_|%)/, display_name, "\\\\\\1") <> "%"

      Repo.replica().all(
        from c in Channel,
        join: u in User,
        on: c.user_id == u.id,
        where: u.is_banned == false,
        where: u.can_stream == true,
        where: not is_nil(u.confirmed_at),
        where: fragment("DATE_PART('day', NOW() - ?) > 5", u.inserted_at),
        where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", u.id, ^costream.host_id),
        where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", ^host.id, c.id),
        where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ^costream.host_id, c.id),
        where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", c.id, ^costream.host_id),
        where: c.inaccessible == false,
        where: c.allow_costream == true,
        where: fragment("not exists(select 1 from costream_invites where costream_id = ? and (? = channel_id and active = 'true' and status != 'expired'))", ^costream.id, c.id),
        where: ilike(u.displayname, ^search_term),
        where: c.id != ^costream.host_id,
        order_by: [asc: u.displayname],
        limit: 10,
        preload: [:user]
      )
    else
      []
    end
  end

  def get_active_invites(costream_id, host_id) do
    Repo.replica().all(
      from ci in CostreamInvites,
      join: invited_channel in Channel,
      on: ci.channel_id == invited_channel.id,
      join: costream in Costream,
      on: ci.costream_id == costream.id,
      join: host_channel in Channel,
      on: costream.host_id == host_channel.id,
      join: invited_user in User,
      on: invited_channel.user_id == invited_user.id,
      where: ci.costream_id == ^costream_id,
      where: ci.active == true,
      where: invited_channel.inaccessible == false,
      where: invited_user.can_stream == true,
      where: invited_user.is_banned == false,
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", invited_channel.user_id, ^host_id),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", host_channel.user_id, invited_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ci.channel_id, ^host_id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ^host_id, ci.channel_id),
      distinct: [ci.channel_id],
      order_by: [asc: ci.channel_id, desc: ci.updated_at],
      preload: [channel: [:user]]
    )
  end

  def get_accepted_invites(costream_id, host_id) do
    Repo.replica().all(
      from ci in CostreamInvites,
      join: invited_channel in Channel,
      on: ci.channel_id == invited_channel.id,
      join: costream in Costream,
      on: ci.costream_id == costream.id,
      join: host_channel in Channel,
      on: costream.host_id == host_channel.id,
      join: invited_user in User,
      on: invited_channel.user_id == invited_user.id,
      where: ci.costream_id == ^costream_id,
      where: ci.active == true,
      where: ci.status in [:accepted, :joined],
      where: invited_channel.inaccessible == false,
      where: invited_user.can_stream == true,
      where: invited_user.is_banned == false,
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", invited_channel.user_id, ^host_id),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", host_channel.user_id, invited_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ci.channel_id, ^host_id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ^host_id, ci.channel_id),
      distinct: [ci.channel_id],
      order_by: [asc: ci.channel_id, desc: ci.status, desc: ci.updated_at],
      preload: [channel: [:user]]
    )
  end

  def get_accepted_and_joined_invites(channel) do
    Repo.replica().all(
      from ci in CostreamInvites,
      join: costream in Costream,
      on: ci.costream_id == costream.id,
      join: host_channel in Channel,
      on: costream.host_id == host_channel.id,
      join: invited_user in User,
      on: ^channel.user_id == invited_user.id,
      where: ci.channel_id == ^channel.id,
      where: ci.active == true,
      where: ci.status in [:accepted, :joined],
      where: fragment(" ? >= (now() - interval '6 months')", ci.updated_at),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", ^channel.user_id, host_channel.id),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", host_channel.user_id, ^channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ^channel.id, host_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", host_channel.id, ^channel.id),
      distinct: [ci.channel_id],
      select_merge: %{active_guests: fragment("array(select u.displayname from costream_invites ci inner join channels c on ci.channel_id = c.id inner join users u on u.id = c.user_id where ci.costream_id = ? and ci.channel_id != ? and ci.active = true and ci.status in ('accepted', 'joined')) as active_guests", ci.costream_id, ^channel.id)},
      order_by: [asc: ci.channel_id, desc: ci.status, desc: ci.updated_at],
      preload: [:costream, channel: [:user]]
    )
  end

  def get_active_ready_hosted_costreams(%Channel{} = channel) do
    from(c in Costream,
    where: c.host_id == ^channel.id,
    where: c.active == true,
    where: c.status in [:started, :ready],
    where: fragment("? >= (now() - interval '6 months')", c.updated_at),
    select_merge: %{active_guests: fragment("array(select u.displayname from costream_invites ci inner join channels c on ci.channel_id = c.id inner join users u on u.id = c.user_id where ci.costream_id = ? and ci.channel_id != ? and ci.active = true and ci.status in ('accepted', 'joined')) as active_guests", c.id, ^channel.id)},
    order_by: [desc: c.status, desc: c.updated_at],
    preload: [:host, :category, :subcategory])
    |> Repo.replica().all()
  end

end
