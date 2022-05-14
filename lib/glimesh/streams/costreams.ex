defmodule Glimesh.Streams.Costreams do
@moduledoc """
  Performs cross-cutting operations for costream, costreaminvites, costreamblockedchannels
"""
  alias Glimesh.Accounts.User
  alias Glimesh.ChannelLookups
  alias Glimesh.Streams.{Channel, Costream, CostreamInvites, CostreamBlockedChannels}
  alias Glimesh.Repo

  def delete_costream(costream_id, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    costream = Costream.get_by_id(costream_id)
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :delete_costream, logged_in_user, [logged_in_channel, costream]) do
      CostreamInvites.delete_all_invites(costream, logged_in_user, logged_in_channel)
      Costream.delete_changeset(%Costream{id: costream_id}, %{active: false})
      |> Repo.update()
    end
  end

  def accept_invite(%User{} = logged_in_user,
    %Channel{} = logged_in_channel,
    %CostreamInvites{} = invite) do
      with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :accept_costream_invite, logged_in_user, [logged_in_channel, invite]) do
        return_value =
          CostreamInvites.update_status_changeset(invite, %{status: :accepted})
          |> Repo.update()
        costream = if invite.costream != nil, do: invite.costream, else: Costream.get_by_id(invite.costream_id)
        maybe_update_status(costream)

        return_value
      end
  end

  def decline_invite(%User{} = logged_in_user,
    %Channel{} = logged_in_channel,
    %CostreamInvites{} = invite) do
      with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :decline_costream_invite, logged_in_user, [logged_in_channel, invite]) do
        CostreamInvites.update_status_changeset(invite, %{status: :declined})
        |> Repo.update()
      end
  end

  def block_invite(%User{} = logged_in_user,
    %Channel{} = logged_in_channel,
    %CostreamInvites{} = invite) do
      with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :block_costream_invite, logged_in_user, [logged_in_channel, invite]) do
        block_channel = ChannelLookups.get_channel(invite.costream.host.id)
        return_value = CostreamBlockedChannels.block_channel(logged_in_user, logged_in_channel, block_channel)
        costream = if invite.costream != nil, do: invite.costream, else: Costream.get_by_id(invite.costream_id)
        maybe_update_status(costream)

        return_value
      end
  end

  def block_channel(%User{} = logged_in_user, %Channel{} = channel, %Channel{} = block_channel) do
    CostreamBlockedChannels.block_channel(logged_in_user, channel, block_channel)
  end

  def unblock_channel(record_id, %User{} = logged_in_user, %Channel{} = user_channel) do
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :unblock_costream_channel, logged_in_user, user_channel) do
      block_record = Repo.get(CostreamBlockedChannels, record_id)
      return_value = CostreamBlockedChannels.update_changeset(block_record, %{active: false})
      |> Repo.update()
      Costream.update_all_active_waiting_costreams_that_guest_accepted_to_ready(user_channel.id)

      return_value
    end
  end

  def start_costream(%Costream{} = costream, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    Costream.start_costream(costream, logged_in_user, logged_in_channel)
  end

  def stop_costream(%Costream{} = costream, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    return_value = Costream.stop_costream(costream, logged_in_user, logged_in_channel)
    maybe_update_status(costream)

    return_value
  end

  def join_costream(%CostreamInvites{} = costream_invite, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    if costream_invite.costream.status == :started do
      Costream.join_costream(costream_invite, logged_in_user, logged_in_channel)
    else
      {:error, costream_invite}
    end
  end

  def leave_costream(%CostreamInvites{} = costream_invite, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    Costream.leave_costream(costream_invite, logged_in_user, logged_in_channel)
  end

  def maybe_update_status(%Costream{} = costream) do
    changeset =
      if CostreamInvites.get_count_accepted_invites(costream) > 0 do
        Costream.status_changeset(costream, %{status: :ready})
      else
        Costream.status_changeset(costream, %{status: :waiting})
      end
    changeset
    |> Repo.update()
  end

  def upload_custom_layout(%Ecto.Changeset{} = details_changeset, upload_file_attributes) do
    # Do bodyguard check here
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:details, details_changeset)
    |> Ecto.Multi.update(:file, &Glimesh.Costreams.CostreamCustomLayout.file_changeset(&1.details, upload_file_attributes))
    |> Repo.transaction()
  end

  def get_approved_custom_layouts(channel_id) do
    Glimesh.Costreams.CostreamCustomLayout.get_approved_layouts(channel_id)
  end

  def get_pending_rejected_custom_layouts(channel_id) do
    Glimesh.Costreams.CostreamCustomLayout.get_pending_rejected_layouts(channel_id)
  end

end
