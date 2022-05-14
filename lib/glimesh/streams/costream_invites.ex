defmodule Glimesh.Streams.CostreamInvites do
  @moduledoc false
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import GlimeshWeb.Gettext

  alias Glimesh.Streams.{Costream, Costreams, CostreamInvites}
  alias Glimesh.Repo
  alias Glimesh.Accounts.User
  alias Glimesh.Streams.Channel

  schema "costream_invites" do
    belongs_to :costream, Glimesh.Streams.Costream
    belongs_to :channel, Glimesh.Streams.Channel

    field :status, Ecto.Enum, values: [:pending, :accepted, :expired, :declined, :joined, :archived], default: :pending
    field :active, :boolean, default: true
    field :type, Ecto.Enum, values: [:regular, :guest], default: :regular
    field :active_guests, {:array, :string}, virtual: true

    timestamps()
  end

  def changeset(%CostreamInvites{} = costream_invites, attrs \\ %{}) do
    costream_invites
    |> cast(attrs, [:status, :active, :type])
    |> cast_assoc(:costream, required: true)
    |> cast_assoc(:channel, required: true)
    |> validate_not_already_accepted()
    |> validate_costream_qualifications()
  end

  def delete_changeset(%CostreamInvites{} = costream_invites, attrs \\ %{}) do
    costream_invites
    |> cast(attrs, [:active])
  end

  def update_status_changeset(%CostreamInvites{} = costream_invites, attrs \\ %{}) do
    costream_invites
    |> cast(attrs, [:active, :status])
  end

  def validate_not_already_accepted(changeset) do
    channel = get_field(changeset, :channel)
    costream = get_field(changeset, :costream)

    if is_nil(costream) or is_nil(channel) do
      add_error(changeset, :channel, gettext("Channel has already accepted an invitation for this costream"))
    else
      perform_not_already_accepted_query(changeset, costream, channel)
    end
  end

  defp perform_not_already_accepted_query(changeset, costream, channel) do
    validate_query = from(
      i in CostreamInvites,
      where: i.costream_id == ^costream.id,
      where: i.channel_id == ^channel.id,
      where: i.status == :accepted
    )

    if Repo.exists?(validate_query) do
      add_error(changeset, :channel, gettext("Channel has already accepted an invitation for this costream"))
    else
      changeset
    end
  end

  def validate_costream_qualifications(changeset) do
    costream = get_field(changeset, :costream)
    channel = get_field(changeset, :channel)

    if is_nil(costream) or is_nil(channel) do
      add_error(changeset, :channel, gettext("Channel does not meet costream qualifications"))
    else
      perform_qualification_query(changeset, costream, channel)
    end
  end

  defp perform_qualification_query(changeset, costream, channel) do
    validate_query = from(
      u in User,
      join: c in Channel,
      on: c.user_id == u.id,
      join: costream in Costream,
      on: costream.id == ^costream.id,
      join: host_channel in Channel,
      on: costream.host_id == host_channel.id,
      where: u.is_banned == false,
      where: u.can_stream == true,
      where: not is_nil(u.confirmed_at),
      where: fragment("DATE_PART('day', NOW() - ?) > 5", u.inserted_at),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", u.id, costream.host_id),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", host_channel.user_id, ^channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", ^channel.id, host_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", host_channel.id, ^channel.id),
      where: c.inaccessible == false,
      where: c.allow_costream == true,
      where: c.id == ^channel.id
    )

    if Repo.exists?(validate_query) do
      changeset
    else
      add_error(changeset, :channel, gettext("Channel does not meet costream qualifications"))
    end
  end

  def create_invite(%User{} = logged_in_user,
    %Channel{} = invited_user,
    %Costream{} = costream,
    attrs \\ %{}) do
      with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :create_costream_invite, logged_in_user, costream) do
        case changeset(%CostreamInvites{costream: costream, channel: invited_user}, attrs) |> Repo.insert() do
          {:ok, invite} ->
            {:ok, invite}
          {:error, changes} ->
            existing_invite = Repo.get_by(CostreamInvites, [costream_id: costream.id, channel_id: invited_user.id, active: false])
            if existing_invite == nil do
              {:error, changes}
            else
              update_status_changeset(existing_invite, %{active: true, status: :pending})
              |> Repo.update()
            end
        end
      end
  end

  def host_delete_invite(%User{} = logged_in_user,
    %Channel{} = logged_in_channel,
    %Costream{} = costream,
    invite_id) do
      with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :delete_host_costream_invites, logged_in_user, [logged_in_channel, costream]) do
        delete_changeset(%CostreamInvites{id: invite_id}, %{active: false})
        |> Repo.update()
        Costreams.maybe_update_status(costream)
      end
  end

  def guest_delete_invite(%User{} = logged_in_user,
    %Channel{} = logged_in_channel,
    invite_id) do
      invite = get_by_id(invite_id)
      with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :delete_guest_costream_invites, logged_in_user, [logged_in_channel, invite]) do
        delete_changeset(%CostreamInvites{id: invite_id}, %{active: false})
        |> Repo.update()
        Costreams.maybe_update_status(invite.costream)
      end
  end

  def delete_all_invites(%Costream{} = costream, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :delete_costream_invites, logged_in_user, [logged_in_channel, costream]) do
      from(ci in CostreamInvites, where: ci.costream_id == ^costream.id)
      |> Repo.update_all(set: [active: false, updated_at: NaiveDateTime.utc_now()])
    end
  end

  def get_accepted_invites(%Costream{} = costream) do
    from(ci in CostreamInvites,
      join: invited_channel in Channel,
      on: ci.channel_id == invited_channel.id,
      join: host_channel in Channel,
      on: host_channel.id == ^costream.host_id,
      where: ci.costream_id == ^costream.id,
      where: ci.status == :accepted,
      where: ci.active == true,
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", invited_channel.user_id, host_channel.id),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", host_channel.user_id, invited_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", invited_channel.id, host_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", host_channel.id, invited_channel.id),
      order_by: [asc: :status, desc: :updated_at],
      preload: [channel: [:user]]
    )
    |> Repo.replica().all()
  end

  def get_by_id(id, preloads \\ [:channel, costream: [:host, :subcategory, :category]]) do
    CostreamInvites
    |> preload(^preloads)
    |> Repo.replica().get(id)
  end

  def get_count_accepted_invites(%Costream{} = costream) do
    from(ci in CostreamInvites,
      join: invited_channel in Channel,
      on: ci.channel_id == invited_channel.id,
      join: host_channel in Channel,
      on: host_channel.id == ^costream.host_id,
      where: ci.costream_id == ^costream.id,
      where: ci.status == :accepted,
      where: ci.active == true,
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", invited_channel.user_id, host_channel.id),
      where: fragment("not exists(select 1 from channel_bans where user_id = ? and channel_id = ? and expires_at is null)", host_channel.user_id, invited_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", invited_channel.id, host_channel.id),
      where: fragment("not exists(select 1 from costream_blocked_channels where channel_id = ? and blocked_channel_id = ? and active = 'true')", host_channel.id, invited_channel.id),
      select: count(ci.id))
    |> Repo.replica().one()
  end

  def join_costream(%CostreamInvites{} = costream_invites) do
    update_status_changeset(costream_invites, %{status: :joined})
    |> Repo.update()
  end

  def leave_costream(%CostreamInvites{} = costream_invites) do
    if costream_invites.type == :guest do
      update_status_changeset(costream_invites, %{status: :expired})
      |> Repo.update()
    else
      update_status_changeset(costream_invites, %{status: :accepted})
      |> Repo.update()
    end
  end

  def get_joined_invites(costream_id) do
    from(ci in CostreamInvites,
      where: ci.costream_id == ^costream_id,
      where: ci.status == :joined,
      where: ci.active == true,
      preload: [costream: [host: [:user, :stream]], channel: [:user, :stream]]
    )
    |> Repo.replica().all()
  end

  def get_joined_invites_channel_ids(costream_id) do
    from(ci in CostreamInvites,
      where: ci.costream_id == ^costream_id,
      where: ci.status == :joined,
      where: ci.active == true,
      select: ci.channel_id
    )
    |> Repo.replica().all()
  end
end
