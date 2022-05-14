defmodule Glimesh.Repo.Migrations.CostreamTables do
  use Ecto.Migration

  def change do
    create_costream_status_enum = "CREATE TYPE costream_status AS ENUM ('started','ready','waiting','archived')"
    drop_costream_status_enum = "DROP TYPE costream_status"
    create_costream_invite_status_enum = "CREATE TYPE costream_invite_status AS ENUM('pending','joined','accepted','expired','declined','archived')"
    drop_costream_invite_status_enum = "DROP TYPE costream_invite_status"
    create_costream_invite_type_enum = "CREATE TYPE costream_invite_type AS ENUM('regular', 'guest')"
    drop_costream_invite_type_enum = "DROP TYPE costream_invite_type"
    create_costream_layout_type_enum = "CREATE TYPE costream_layout_type AS ENUM('host', 'carousel', 'split_vertical', 'split_horizontal', 'stacked_right', 'stacked_left', 'stacked_top', 'stacked_bottom', 'triforce', 'grid', 'two_columns', 'three_columns', 'custom')"
    drop_costream_layout_type_enum = "DROP TYPE costream_layout_type"

    execute(create_costream_status_enum, drop_costream_status_enum)
    execute(create_costream_invite_status_enum, drop_costream_invite_status_enum)
    execute(create_costream_invite_type_enum, drop_costream_invite_type_enum)
    execute(create_costream_layout_type_enum, drop_costream_layout_type_enum)

    create table(:costream_custom_layouts) do
      add :channel_id, references(:channels), null: false
      add :name, :string, null: false
      add :max_participants, :integer, null: false
      add :visible_participants, :integer, null: false
      add :approved_at, :naive_datetime, default: nil
      add :rejected_at, :naive_datetime, default: nil
      add :rejected_reason, :string, default: nil
      add :reviewed_by_id, references(:users), default: nil
      add :original, :string

      timestamps()
    end

    create table(:costreams) do
      add :name, :string, null: false
      add :status, :costream_status
      add :active, :boolean, default: true
      add :layout_type, :costream_layout_type, default: "host"
      add :custom_layout_id, references(:costream_custom_layouts), null: true
      add :max_participants, :integer, default: 2
      add :host_channel_id, references(:channels), null: false
      add :category_id, :integer
      add :subcategory_id, :integer
      add :category_tags, {:array, :integer}

      timestamps()
    end

    create table(:costream_invites) do
      add :status, :costream_invite_status
      add :active, :boolean, default: true
      add :type, :costream_invite_type
      add :channel_id, references(:channels), null: false
      add :costream_id, references(:costreams), null: false

      timestamps()
    end

    alter table(:channels) do
      add :allow_costream, :boolean, default: false
      add :use_costream_tags, :boolean, default: false
      add :costream_id, references(:costreams), default: nil
      add :costream_active, :boolean, default: false
    end

    create table(:costream_blocked_channels) do
      add :channel_id, references(:channels), null: false
      add :blocked_channel_id, references(:channels), null: false
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:costream_blocked_channels, [:channel_id, :blocked_channel_id])
  end
end
