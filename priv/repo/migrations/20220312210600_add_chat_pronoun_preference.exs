defmodule Glimesh.Repo.Migrations.AddChatPronounPreference do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :show_pronoun_chat, :boolean, default: false, null: true
    end
  end
end
