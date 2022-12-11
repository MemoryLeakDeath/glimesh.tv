defmodule Glimesh.Streams.Tag do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :icon, :string
    field :name, :string
    field :slug, :string

    field :count_usage, :integer, default: 0

    many_to_many :channels, Glimesh.Streams.Channel, join_through: "channel_tags"

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :slug, :icon, :count_usage])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 18)
    |> validate_format(:name, ~r/^[A-Za-z0-9: -]{2,18}$/)
    |> set_slug_attribute()
    |> unique_constraint(:slug)
  end

  def set_slug_attribute(changeset) do
    if name = get_field(changeset, :name) do
      put_change(changeset, :slug, Slug.slugify(name))
    else
      # When nil let fail normally
      changeset
    end
  end
end
