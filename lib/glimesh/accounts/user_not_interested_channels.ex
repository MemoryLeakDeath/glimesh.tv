defmodule Glimesh.Accounts.UserNotInterestedChannels do
  @moduledoc false

  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  alias Glimesh.Accounts.User
  alias Glimesh.Accounts.UserNotInterestedChannels
  alias Glimesh.Repo


  schema "user_not_interested_channels" do
    belongs_to :user, User
    belongs_to :channel, Glimesh.Streams.Channel

    timestamps()
  end

  @doc """
  A changeset for all of the user configurable options
  """
  def changeset(user_not_interested, attrs \\ %{}) do
    user_not_interested
    |> cast(attrs, [])
    |> cast_assoc(:user)
    |> cast_assoc(:channel)
    |> unique_constraint([:user_id, :channel_id])
    |> validate_required([:user, :channel])
  end

  def add_not_interested(%UserNotInterestedChannels{} = user_not_interested, %User{} = user, channel_id) do
    user_not_interested
    |> changeset(%{user: user, channel_id: channel_id})
    |> Repo.insert()
  end

  def remove_not_interested(id) do
    Repo.get_by(UserNotInterestedChannels, id: id)
    |> Repo.delete()
  end
end
