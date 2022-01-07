defmodule Glimesh.Chat.Effects.Badges.GCTBadge do
  @moduledoc """
  Badge for members of the gct team
  """
  import GlimeshWeb.Gettext
  import Phoenix.LiveView.Helpers

  def render(assigns \\ %{}) do
    ~H"""
      <span class={["badge", "badge-success"]} title={gettext("Glimesh Community Team member")}>
        <i class={["fas", "fa-users"]} style={"text-color: white;"}></i>
      </span>
    """
  end
end
