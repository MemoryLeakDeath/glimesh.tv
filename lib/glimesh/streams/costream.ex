defmodule Glimesh.Streams.Costream do
  @moduledoc false
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Glimesh.Accounts.User
  alias Glimesh.Streams.{Channel, Costream, CostreamInvites}
  alias Glimesh.Repo
  alias Glimesh.ChannelCategories
  alias Glimesh.Streams.Tag

  schema "costreams" do
    belongs_to :host, Glimesh.Streams.Channel, source: :host_channel_id
    belongs_to :category, Glimesh.Streams.Category
    belongs_to :subcategory, Glimesh.Streams.Subcategory, on_replace: :nilify
    belongs_to :custom_layout, Glimesh.Costreams.CostreamCustomLayout, on_replace: :nilify
    has_many :guests, Glimesh.Streams.CostreamInvites, on_replace: :nilify

    field :name, :string
    field :category_tags, {:array, :integer}
    field :status, Ecto.Enum, values: [:started, :ready, :waiting, :archived], default: :waiting
    field :active, :boolean, default: true
    field :layout_type, Ecto.Enum, values: [:host, :carousel, :split_vertical, :split_horizontal, :stacked_right, :stacked_left, :stacked_top, :stacked_bottom, :triforce, :grid, :two_columns, :three_columns, :custom], default: :host
    field :max_participants, :integer, default: 2
    field :active_guests, {:array, :string}, virtual: true


    timestamps()
  end

  def changeset(%Costream{} = costream, attrs \\ %{}) do
    costream
    |> cast(attrs, [
      :name,
      :status,
      :active,
      :layout_type,
      :max_participants,
      :host_id,
      :category_id
    ])
    |> validate_required([:host_id, :name])
    |> validate_number(:max_participants, greater_than: 1)
    |> maybe_put_subcategory(:subcategory, attrs)
    |> maybe_put_tags(:category_tags, attrs)
  end

  def delete_changeset(%Costream{} = costream, attrs \\ %{}) do
    costream
    |> cast(attrs, [:active])
  end

  def status_changeset(%Costream{} = costream, attrs \\ %{}) do
    costream
    |> cast(attrs, [:status, :active])
  end

  def create_costream(%Costream{} = costream, attrs) do
    costream_changeset = changeset(costream, attrs)
    costream_changeset
    |> Repo.insert()
  end

  def update_costream(%Costream{} = costream, attrs) do
    costream_changeset = changeset(costream, attrs)
    costream_changeset
    |> Repo.update()
  end

  def list_costream_types do
    Keyword.get(Application.get_env(:glimesh, :costream_layout_types), :layout_types, [])
  end

  def get_max_participants do
    Keyword.get(Application.get_env(:glimesh, :costream_max_participants), :max, 6)
  end

  def get_by_id(id) do
    guests_query = from(
      g in CostreamInvites,
      join: c in assoc(g, :costream),
      where: g.active == true,
      preload: [channel: [:user]]
      )
    Costream
    |> where([c], c.id == ^id)
    |> preload([:host, :subcategory, :category, guests: ^guests_query])
    |> Repo.replica().one()
  end

  def maybe_put_tags(changeset, key, %{"category_tags" => _tags} = attrs) do
    # Make sure we're not accidentally unsetting tags
    changeset |> put_change(key, parse_tags(attrs))
  end

  def maybe_put_tags(changeset, _key, _attrs) do
    changeset
  end

  def maybe_put_subcategory(changeset, key, %{"subcategory" => subcategory_json})
      when subcategory_json == "" do
    changeset |> put_assoc(key, nil)
  end

  def maybe_put_subcategory(changeset, key, %{"subcategory" => subcategory_json})
      when is_binary(subcategory_json) do
    case Jason.decode(subcategory_json) do
      {:ok, [%{"value" => value, "category_id" => category_id}]} ->
        slug = Slug.slugify(value)

        subcategory =
          if existing =
               ChannelCategories.get_subcategory_by_category_id_and_slug(category_id, slug) do
            existing
          else
            {:ok, category} =
              ChannelCategories.create_subcategory(%{
                name: value,
                user_created: true,
                category_id: category_id
              })

            category
          end

        changeset |> put_assoc(key, subcategory)

      _ ->
        changeset
    end
  end

  def maybe_put_subcategory(changeset, _, _) do
    changeset
  end

  def parse_tags(attrs) do
    case Jason.decode(attrs["category_tags"] || "[]") do
      {:ok, content} -> insert_and_get_all(content)
      _ -> insert_and_get_all([])
    end
  end

  defp insert_and_get_all([]) do
    []
  end

  defp insert_and_get_all(inputs) do
    Enum.map(inputs, fn input ->
      {:ok, tag} =
        Glimesh.ChannelCategories.upsert_tag(
          %Tag{},
          %{
            category_id: input["category_id"],
            name: input["value"]
          }
        )
      tag.id
    end)
  end

  def update_all_active_waiting_costreams_that_guest_accepted_to_ready(channel_id) do
    from(c in Costream,
      join: ci in CostreamInvites,
      on: ci.costream_id == c.id,
      where: ci.channel_id == ^channel_id,
      where: ci.active == true,
      where: ci.status == :accepted,
      where: c.active == true,
      where: c.status == :waiting)
    |> Repo.update_all(set: [status: :ready, updated_at: NaiveDateTime.utc_now()])
  end

  def start_costream(%Costream{} = costream, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :start_costream, logged_in_user, [logged_in_channel, costream]) do
      if logged_in_channel.use_costream_tags do
        Channel.start_costreaming(
          logged_in_channel,
          costream.id,
          %{title: costream.name,
            category_id: costream.category_id,
            subcategory_id: costream.subcategory_id,
            tags: costream.category_tags
          })
      else
        Channel.start_costreaming(logged_in_channel, costream.id)
      end
      status_changeset(costream, %{status: :started})
      |> Repo.update()
    end
  end

  def stop_costream(%Costream{} = costream, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :stop_costream, logged_in_user, [logged_in_channel, costream]) do
      Channel.stop_costreaming(logged_in_channel)
      status_changeset(costream, %{status: :ready})
      |> Repo.update()
    end
  end

  def join_costream(%CostreamInvites{} = costream_invite, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :join_costream, logged_in_user, [logged_in_channel, costream_invite]) do
      if logged_in_channel.use_costream_tags do
        Channel.start_costreaming(
          logged_in_channel,
          costream_invite.costream.id,
          %{title: costream_invite.costream.name,
            category_id: costream_invite.costream.category_id,
            subcategory_id: costream_invite.costream.subcategory_id,
            tags: costream_invite.costream.category_tags
          })
      else
        Channel.start_costreaming(logged_in_channel, costream_invite.costream.id)
      end
      CostreamInvites.join_costream(costream_invite)
    end
  end

  def leave_costream(%CostreamInvites{} = costream_invite, %User{} = logged_in_user, %Channel{} = logged_in_channel) do
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :leave_costream, logged_in_user, [logged_in_channel, costream_invite]) do
      Channel.stop_costreaming(logged_in_channel)
      CostreamInvites.leave_costream(costream_invite)
    end
  end
end
