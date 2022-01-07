defmodule Glimesh.Chat.Effects.Badges.ChannelSubscriberBadge do
  @moduledoc """
  Badge for channel subscribers
  """

  import GlimeshWeb.Gettext
  import Phoenix.LiveView.Helpers

  def render(assigns \\ %{}) do
    ~H"""
      <span class={["badge", "badge-secondary"]} title={gettext("Channel Subscriber")}>
        <i class={["fas", "fa-trophy"]} style={"text-color: white;"}></i>
      </span>
    """
  end
end
