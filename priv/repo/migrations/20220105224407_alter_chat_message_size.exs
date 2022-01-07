defmodule Glimesh.Repo.Migrations.AlterChatMessageSize do
  use Ecto.Migration

  alias Glimesh.Repo

  def up do
    alter table(:chat_messages) do
      modify :message, :string, size: 500
    end
  end

  def down do
    drop_backup = "drop table if exists chat_messages_backup"
    create_backup = "select * into chat_messages_backup from chat_messages"
    truncate_chat = "truncate table chat_messages"
    {:ok, %{:num_rows => _rows}} = Repo.query(drop_backup)
    {:ok, %{:num_rows => _rows}} = Repo.query(create_backup)
    {:ok, %{:num_rows => _rows}} = Repo.query(truncate_chat)

    flush()

    copy_from_backup = """
      insert into chat_messages (message, user_id, inserted_at, updated_at, is_visible, channel_id, is_followed_message, \
      tokens, is_subscription_message) \
      (select cm.message, user_id, inserted_at, updated_at, is_visible, \
      channel_id, is_followed_message, tokens, is_subscription_message \
      from chat_messages_backup \
      inner join \
        (select id, unnest(ARRAY[substr(message,1,255), nullif(substr(message,256), '')]) as message from chat_messages_backup) as cm \
      on (chat_messages_backup.id = cm.id and cm.message is not null)) \
    """
    {:ok, %{:num_rows => _rows}} = Repo.query(copy_from_backup)
    flush()

    alter table(:chat_messages) do
      modify :message, :string
    end

    flush()
    Repo.query(drop_backup)
  end
end
