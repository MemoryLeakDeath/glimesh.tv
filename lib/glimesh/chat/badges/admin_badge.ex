defmodule Glimesh.Chat.Effects.Badges.AdminBadge do
  @moduledoc """
  Badge for streamers
  """
  import GlimeshWeb.Gettext
  import Phoenix.LiveView.Helpers

  def render(assigns \\ %{}) do
    ~H"""
      <span class={["badge", "badge-danger"]} title={gettext("Glimesh Staff")}>
        <i class={["fas", "fa-database"]} style={"text-color: white;"}></i>
      </span>
    """
  end
end
