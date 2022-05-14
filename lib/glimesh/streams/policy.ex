defmodule Glimesh.Streams.Policy do
  @moduledoc """
  Glimesh Streams Policy
  """

  @behaviour Bodyguard.Policy

  alias Glimesh.Accounts.User
  alias Glimesh.Streams.Channel
  alias Glimesh.Streams.Costream
  alias Glimesh.Streams.CostreamInvites

  def authorize(:create_channel, %User{}, _nothing), do: true

  def authorize(
        :start_stream,
        %User{can_stream: can_stream, confirmed_at: confirmed_at},
        _nothing
      )
      when can_stream and not is_nil(confirmed_at),
      do: true

  # Admins
  def authorize(:update_channel, %User{is_admin: true}, _channel), do: true
  def authorize(:delete_channel, %User{is_admin: true}, _channel), do: true

  def authorize(:show_channel_moderator, %User{is_admin: true}, _channel), do: true
  def authorize(:create_channel_moderator, %User{is_admin: true}, _channel), do: true
  def authorize(:update_channel_moderator, %User{is_admin: true}, _channel), do: true
  def authorize(:delete_channel_moderator, %User{is_admin: true}, _channel), do: true

  def authorize(:delete_hosting_target, %User{is_admin: true}, _channel), do: true

  def authorize(:block_costream_channel, %User{is_admin: true}, _channel), do: true
  def authorize(:unblock_costream_channel, %User{is_admin: true}, _channel), do: true
  def authorize(:delete_costream_invites, %User{is_admin: true}, [_channel, _costream]), do: true
  def authorize(:delete_host_costream_invites, %User{is_admin: true}, [_channel, _costream]), do: true
  def authorize(:delete_guest_costream_invites, %User{is_admin: true}, [_channel, _invite]), do: true
  def authorize(:delete_costream, %User{is_admin: true}, [_channel, _costream]), do: true
  def authorize(:edit_costream, %User{is_admin: true}, [_channel, _costream]), do: true
  def authorize(:start_costream, %User{is_admin: true}, [_channel, _costream]), do: true
  def authorize(:stop_costream, %User{is_admin: true}, [_channel, _costream]), do: true
  def authorize(:accept_costream_invite, %User{is_admin: true}, [_channel, _invite]), do: true
  def authorize(:decline_costream_invite, %User{is_admin: true}, [_channel, _invite]), do: true
  def authorize(:block_costream_invite, %User{is_admin: true}, [_channel, _invite]), do: true
  def authorize(:costream_dashboard_view, %User{is_admin: true}, [_channel, _invite]), do: true
  def authorize(:join_costream, %User{is_admin: true}, [_channel, _invite]), do: true
  def authorize(:leave_costream, %User{is_admin: true}, [_channel, _invite]), do: true

  # GCT
  def authorize(:update_channel, %User{is_gct: true}, _channel), do: true
  def authorize(:delete_channel, %User{is_gct: true}, _channel), do: true

  def authorize(:show_channel_moderator, %User{is_gct: true}, _channel), do: true
  def authorize(:create_channel_moderator, %User{is_gct: true}, _channel), do: true
  def authorize(:update_channel_moderator, %User{is_gct: true}, _channel), do: true
  def authorize(:delete_channel_moderator, %User{is_gct: true}, _channel), do: true

  def authorize(:block_costream_channel, %User{is_gct: true}, _channel), do: true
  def authorize(:unblock_costream_channel, %User{is_gct: true}, _channel), do: true
  def authorize(:delete_host_costream_invites, %User{is_gct: true}, [_channel, _costream]), do: true
  def authorize(:delete_guest_costream_invites, %User{is_gct: true}, [_channel, _invite]), do: true
  def authorize(:delete_costream_invites, %User{is_gct: true}, [_channel, _costream]), do: true
  def authorize(:delete_costream, %User{is_gct: true}, [_channel, _costream]), do: true
  def authorize(:edit_costream, %User{is_gct: true}, [_channel, _costream]), do: true
  def authorize(:start_costream, %User{is_gct: true}, [_channel, _costream]), do: true
  def authorize(:stop_costream, %User{is_gct: true}, [_channel, _costream]), do: true
  def authorize(:accept_costream_invite, %User{is_gct: true}, [_channel, _invite]), do: true
  def authorize(:decline_costream_invite, %User{is_gct: true}, [_channel, _invite]), do: true
  def authorize(:block_costream_invite, %User{is_gct: true}, [_channel, _invite]), do: true
  def authorize(:costream_dashboard_view, %User{is_gct: true}, [_channel, _invite]), do: true
  def authorize(:join_costream, %User{is_gct: true}, [_channel, _invite]), do: true
  def authorize(:leave_costream, %User{is_gct: true}, [_channel, _invite]), do: true

  # Editors
  def authorize(:edit_channel_title_and_tags, %User{id: user_id}, [
        %Channel{user_id: channel_user_id},
        is_editor
      ])
      when user_id == channel_user_id or is_editor,
      do: true

  # Streamers
  def authorize(:update_channel, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:delete_channel, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:show_channel_moderator, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:create_channel_moderator, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:update_channel_moderator, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:delete_channel_moderator, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:delete_hosting_target, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:add_hosting_target, %User{id: user_id}, %Channel{user_id: channel_user_id})
      when user_id == channel_user_id,
      do: true

  def authorize(:update_costream_permissions, %User{id: user_id}, %Channel{user_id: channel_user_id})
    when user_id == channel_user_id,
    do: true

  def authorize(:create_costream_invite, %User{id: user_id}, %Costream{host_id: host_id})
    when user_id == host_id,
    do: true

  def authorize(:block_costream_channel, %User{id: user_id}, %Channel{user_id: channel_user_id})
    when user_id == channel_user_id,
    do: true

  def authorize(:unblock_costream_channel, %User{id: user_id}, %Channel{user_id: channel_user_id})
    when user_id == channel_user_id,
    do: true

  def authorize(:delete_host_costream_invites, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %Costream{host_id: host_id}])
    when (user_id == channel_user_id and channel_id == host_id),
    do: true

  def authorize(:delete_guest_costream_invites, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %CostreamInvites{channel_id: guest_id}])
    when (user_id == channel_user_id and channel_id == guest_id),
    do: true

  def authorize(:delete_costream_invites, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %Costream{host_id: host_id}])
    when (user_id == channel_user_id and channel_id == host_id),
    do: true

  def authorize(:delete_costream, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %Costream{host_id: host_id}])
    when (user_id == channel_user_id and channel_id == host_id),
    do: true

  def authorize(:edit_costream, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %Costream{host_id: host_id}])
    when (user_id == channel_user_id and channel_id == host_id),
    do: true

  def authorize(:start_costream, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %Costream{host_id: host_id}])
    when (user_id == channel_user_id and channel_id == host_id),
    do: true

  def authorize(:stop_costream, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %Costream{host_id: host_id}])
    when (user_id == channel_user_id and channel_id == host_id),
    do: true

  def authorize(:accept_costream_invite, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %CostreamInvites{channel_id: channel_invite_id}])
    when (user_id == channel_user_id and channel_id == channel_invite_id),
    do: true

  def authorize(:decline_costream_invite, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %CostreamInvites{channel_id: channel_invite_id}])
    when (user_id == channel_user_id and channel_id == channel_invite_id),
    do: true

  def authorize(:block_costream_invite, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %CostreamInvites{channel_id: channel_invite_id}])
    when (user_id == channel_user_id and channel_id == channel_invite_id),
    do: true

  def authorize(:costream_dashboard_view, %User{id: user_id}, %Channel{user_id: channel_user_id})
    when (user_id == channel_user_id),
    do: true

  def authorize(:join_costream, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %CostreamInvites{channel_id: invited_channel_id}])
    when (user_id == channel_user_id and channel_id == invited_channel_id),
    do: true

  def authorize(:leave_costream, %User{id: user_id}, [%Channel{id: channel_id, user_id: channel_user_id}, %CostreamInvites{channel_id: invited_channel_id}])
    when (user_id == channel_user_id and channel_id == invited_channel_id),
    do: true

  def authorize(_, _, _), do: false
end
