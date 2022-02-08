defmodule Glimesh.Repo.Migrations.AddUsersNotInterestedChannels do
  use Ecto.Migration

  def change do
    create table(:users_not_interested_channels) do
      add :user_id, references(:users, column: :id), null: false
      add :channel_id, references(:channels, column: :id), null: false

      timestamps()
    end

    create unique_index(:users_not_interested_channels, [:user_id, :channel_id])
  end
end
