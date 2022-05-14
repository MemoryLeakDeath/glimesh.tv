defmodule Glimesh.Streams.CostreamBlockedChannels do
  @moduledoc false
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Glimesh.Streams.CostreamBlockedChannels
  alias Glimesh.Accounts.User
  alias Glimesh.Streams.Channel
  alias Glimesh.Repo

  schema "costream_blocked_channels" do
    belongs_to :channel, Glimesh.Streams.Channel
    belongs_to :blocked_channel, Glimesh.Streams.Channel, foreign_key: :blocked_channel_id

    field :active, :boolean, default: true

    timestamps()
  end

  def changeset(%CostreamBlockedChannels{} = blocked, attrs \\ %{}) do
    blocked
    |> cast(attrs, [:active])
    |> cast_assoc(:channel, required: true)
    |> cast_assoc(:blocked_channel, required: true)
    |> unique_constraint([:channel, :blocked_channel])
  end

  def update_changeset(%CostreamBlockedChannels{} = blocked, attrs \\ %{}) do
    blocked
    |> cast(attrs, [:active, :channel_id, :blocked_channel_id])
    |> unique_constraint([:channel, :blocked_channel])
  end

  def block_channel(%User{} = logged_in_user, %Channel{} = channel, %Channel{} = block_channel) do
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :block_costream_channel, logged_in_user, channel) do
      new_block = %CostreamBlockedChannels{channel: channel, blocked_channel: block_channel}
      if blocked = already_exists?(new_block) do
        update_existing(blocked)
      else
        insert_new(new_block)
      end
    end
  end

  defp already_exists?(%CostreamBlockedChannels{} = block) do
    Repo.one(from b in CostreamBlockedChannels, where: b.channel_id == ^block.channel.id and b.blocked_channel_id == ^block.blocked_channel.id)
  end

  defp insert_new(%CostreamBlockedChannels{} = changes) do
    changeset(changes)
    |> Repo.insert()
  end

  defp update_existing(%CostreamBlockedChannels{} = changes) do
    update_changeset(changes, %{active: true})
    |> Repo.update()
  end

  def get_blocked_channels(%Channel{} = user_channel) do
    from(b in CostreamBlockedChannels,
        where: b.channel_id == ^user_channel.id,
        where: b.active == true,
        preload: [blocked_channel: [:user]])
    |> Repo.replica().all()
  end

end
