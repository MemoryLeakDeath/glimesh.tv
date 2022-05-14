defmodule GlimeshWeb.CostreamingLive.CustomLayoutManage do
  use GlimeshWeb, :live_view

  alias Glimesh.ChannelLookups
  alias Glimesh.Streams.{Costreams, Costream}
  alias Glimesh.Costreams.CostreamCustomLayout

  @impl true
  def mount(_params, session, socket) do
    user = Glimesh.Accounts.get_user_by_session_token(session["user_token"])
    channel = ChannelLookups.get_channel_for_user(user)

    approved_layouts = CostreamCustomLayout.get_approved_layouts(channel.id)
    pending_layouts = CostreamCustomLayout.get_pending_rejected_layouts(channel.id)

    if length(approved_layouts ++ pending_layouts) > 0 do
      {:ok,
        socket
        |> assign(:user, user)
        |> assign(:channel, channel)
        |> assign(:approved_layouts, approved_layouts)
        |> assign(:pending_layouts, pending_layouts)
        |> put_page_title(format_page_title(gettext("Manage Co-streaming Custom Layouts")))
      }
    else
      {:ok, redirect(socket, to: Routes.costreaming_settings_path(socket, :custom_layout_upload))}
    end
  end
end
