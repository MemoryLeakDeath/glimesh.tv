defmodule GlimeshWeb.CostreamingLive.CostreamingSettingsController do
  use GlimeshWeb, :controller

  alias Phoenix.LiveView.Controller
  alias GlimeshWeb.CostreamingLive.{CustomLayoutUpload,CustomLayoutManage,Index,IndexHost,Manage}
  alias Glimesh.Streams.Costream
  alias Glimesh.ChannelLookups

  plug :put_layout, "user-sidebar.html"

  action_fallback GlimeshWeb.FallbackController

  def index(conn, _params) do
    conn
    |> Controller.live_render(Index)
  end

  def index_host(conn, _params) do
    conn
    |> Controller.live_render(IndexHost)
  end

  def create(conn, _params) do
    conn
    |> Controller.live_render(Manage, session: %{"live_action" => "create"})
  end

  def edit(conn, params) do
    costream = Costream.get_by_id(params["id"])
    channel = ChannelLookups.get_channel_for_user_id(conn.assigns.current_user.id)
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :edit_costream, conn.assigns.current_user, [channel, costream]) do
      conn
      |> Controller.live_render(Manage, session: %{"live_action" => "edit", "edit_costream" => costream})
    end
  end

  def custom_layout_upload(conn, _params) do
    conn
    |> Controller.live_render(CustomLayoutUpload)
  end

  def custom_layout_manage(conn, _params) do
    conn
    |> Controller.live_render(CustomLayoutManage)
  end
end
