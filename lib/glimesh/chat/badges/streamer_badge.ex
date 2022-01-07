defmodule Glimesh.Chat.Effects.Badges.StreamerBadge do
  @moduledoc """
  Badge for streamers
  """
  import GlimeshWeb.Gettext
  import Phoenix.LiveView.Helpers

  def render(assigns \\ %{}) do
    ~H"""
      <span class={["badge", "badge-primary"]} title={gettext("Streamer")}>
        <i class={["fas", "fa-tv"]} style={"text-color: white;"}></i>
      </span>
    """
  end
end
