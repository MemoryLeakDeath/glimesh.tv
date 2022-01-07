defmodule Glimesh.Chat.Effects.Badges.PronounBadge do
  @moduledoc """
  Badge for streamers
  """
  import GlimeshWeb.Gettext
  import Phoenix.LiveView.Helpers

  def render(assigns) do
    ~H"""
      <%= if @chat_user.show_pronoun_chat and @chat_user.pronoun != nil and @chat_user.pronoun !== "None" do %>
        <span class={["badge", "badge-success", "ml-1"]} title={@chat_user.pronoun}>
          <%= @chat_user.pronoun %>
        </span>
      <% end %>
    """
  end
end
