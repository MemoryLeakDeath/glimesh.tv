defmodule Glimesh.Chat.Effects.Badges.ModeratorBadge do
  @moduledoc """
  Badge for moderators
  """

  import GlimeshWeb.Gettext
  import Phoenix.LiveView.Helpers

  def render(assigns \\ %{}) do
    ~H"""
      <span class={["badge", "badge-primary"]} title={gettext("Moderator")}>
        <i class={["fas", "fa-shield-alt"]} style={"text-color: white;"}></i>
      </span>
    """
  end
end
