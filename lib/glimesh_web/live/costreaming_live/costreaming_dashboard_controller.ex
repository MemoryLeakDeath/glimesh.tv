defmodule GlimeshWeb.CostreamingLive.CostreamingDashboardController do
  use GlimeshWeb, :controller

  alias Phoenix.LiveView.Controller
  alias GlimeshWeb.CostreamingLive.Dashboard

  action_fallback GlimeshWeb.FallbackController

  def dashboard(conn, _params) do
    conn
    |> Controller.live_render(Dashboard)
  end
end
