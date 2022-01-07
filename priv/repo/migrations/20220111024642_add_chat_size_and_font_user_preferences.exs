defmodule Glimesh.Repo.Migrations.AddChatSizeAndFontUserPreferences do
  use Ecto.Migration

  def change do
    alter table(:user_preferences) do
      add :chat_text_size, :integer, default: 16, null: false
      add :chat_font, :string, null: true
    end
  end
end
