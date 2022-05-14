defmodule Glimesh.Costreams.CostreamCustomLayout do
  @moduledoc false

  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Glimesh.Costreams.CostreamCustomLayout
  alias Glimesh.Repo

  schema "costream_custom_layouts" do
    belongs_to :channel, Glimesh.Streams.Channel
    field :name, :string
    field :max_participants, :integer
    field :visible_participants, :integer

    field :approved_at, :naive_datetime
    field :rejected_at, :naive_datetime
    field :rejected_reason, :string
    belongs_to :reviewed_by, Glimesh.Accounts.User
    has_many :costreams, Glimesh.Streams.Costream, foreign_key: :custom_layout_id

    field :original, Glimesh.Uploaders.CostreamCustomLayout.Type

    timestamps()
  end

  @doc false
  def changeset(custom_layout, attrs \\ %{}) do
    custom_layout
    |> cast(attrs, [
      :name,
      :max_participants,
      :visible_participants,
    ])
    |> cast_assoc(:channel)
    |> validate_required([:channel, :name, :max_participants, :visible_participants])
    |> validate_length(:name, min: 2, max: 50)
  end

  def new_changeset(custom_layout, attrs \\ %{}) do
    custom_layout
    |> cast(attrs, [:name, :max_participants, :visible_participants])
  end

  def review_changeset(custom_layout, reviewer, attrs \\ %{}) do
    custom_layout
    |> cast(attrs, [:approved_at, :rejected_at, :rejected_reason])
    |> put_assoc(:reviewed_by, reviewer)
  end

  def file_changeset(%Glimesh.Costreams.CostreamCustomLayout{} = layout, attrs) do
    layout
    |> cast_attachments(attrs, [:original], allow_paths: true)
    |> validate_required(:original)
  end

  def get_approved_layouts(channel_id) do
    from(cl in CostreamCustomLayout,
    where: cl.channel_id == ^channel_id,
    where: not is_nil(cl.approved_at),
    order_by: [desc: cl.inserted_at],
    preload: [:costreams]
    )
    |> Repo.replica().all()
  end

  def get_pending_rejected_layouts(channel_id) do
    from(cl in CostreamCustomLayout,
    where: cl.channel_id == ^channel_id,
    where: is_nil(cl.approved_at),
    order_by: [desc: cl.inserted_at],
    preload: [:costreams]
    )
    |>Repo.replica().all()
  end
end
