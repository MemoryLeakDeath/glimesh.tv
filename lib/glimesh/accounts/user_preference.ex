defmodule Glimesh.Accounts.UserPreference do
  @moduledoc false

  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "user_preferences" do
    belongs_to :user, Glimesh.Accounts.User

    field :locale, :string, default: "en"
    field :site_theme, :string, default: "dark"
    field :show_timestamps, :boolean, default: false
    field :show_mod_icons, :boolean, default: true
    field :show_mature_content, :boolean, default: false
    field :gift_subs_enabled, :boolean, default: true
    field :chat_text_size, :integer, default: 16
    field :chat_font, :string

    timestamps()
  end

  @doc """
  A changeset for all of the user configurable options
  """
  def changeset(user_preferences, attrs) do
    user_preferences
    |> cast(attrs, [
      :locale,
      :site_theme,
      :show_timestamps,
      :show_mature_content,
      :show_mod_icons,
      :gift_subs_enabled,
      :chat_text_size,
      :chat_font
    ])
    |> unique_constraint(:user_id)
    |> validate_required(:chat_text_size)
  end
end
