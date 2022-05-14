defmodule GlimeshWeb.CostreamingLive.Dashboard do
  use GlimeshWeb, :live_view

  alias Glimesh.ChannelLookups
  alias Glimesh.Costreams.CostreamLookups
  alias Glimesh.Streams.{Costream, Costreams, CostreamInvites}

  @impl true
  def mount(_params, %{"streamer" => streamer} = session, socket) do
    current_user = Glimesh.Accounts.get_user_by_session_token(session["user_token"])
    channel = ChannelLookups.get_channel_for_user(streamer)
    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :costream_dashboard_view, current_user, channel) do
      initial_mount(streamer, channel, socket)
    end
  end

  defp initial_mount(streamer, channel, socket) do
    accepted_invites = CostreamLookups.get_accepted_and_joined_invites(channel)
    ready_hosted = CostreamLookups.get_active_ready_hosted_costreams(channel)
    nothing_to_show = (length(accepted_invites) < 1 and length(ready_hosted) < 1)

    {:ok,
      socket
      |> assign(:streamer, streamer)
      |> assign(:channel, channel)
      |> assign(:invites, accepted_invites)
      |> assign(:hosted, ready_hosted)
      |> assign(:nothing_to_show, nothing_to_show)
      |> assign(:show_participants, false)
      |> assign(:show_participants_costream_name, "")
      |> assign(:show_participants_channels, [])
      |> assign(:invitations_tab_active, "show active")
      |> assign(:invitations_tab_bar_active, "active")
      |> assign(:hosted_tab_active, "")
      |> assign(:hosted_tab_bar_active, "")
    }
  end

  @impl true
  def handle_event("hide_costream_dashboard_modal", _value, socket) do
    {:noreply,
     socket
     |> push_patch(to: Routes.user_stream_path(socket, :index, socket.assigns.streamer.username))
    }
  end

  def handle_event("activate_invitations_tab", _value, socket) do
    {:noreply,
      socket
      |> assign(:invitations_tab_active, "show active")
      |> assign(:invitations_tab_bar_active, "active")
      |> assign(:hosted_tab_active, "")
      |> assign(:hosted_tab_bar_active, "")
    }
  end

  def handle_event("activate_hosted_tab", _value, socket) do
    {:noreply,
      socket
      |> assign(:invitations_tab_active, "")
      |> assign(:invitations_tab_bar_active, "")
      |> assign(:hosted_tab_active, "show active")
      |> assign(:hosted_tab_bar_active, "active")
    }
  end

  def handle_event("start_costream", %{"id" => id}, socket) do
    costream = Costream.get_by_id(id)
    case Costreams.start_costream(costream, socket.assigns.streamer, socket.assigns.channel) do
      {:ok, _changeset} ->
        ready_hosted = CostreamLookups.get_active_ready_hosted_costreams(socket.assigns.channel)
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Started co-stream successfully"))
          |> assign(:hosted, ready_hosted)
        }
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Unable to start co-stream"))
        }
    end
  end

  def handle_event("stop_costream", %{"id" => id}, socket) do
    costream = Costream.get_by_id(id)
    case Costreams.stop_costream(costream, socket.assigns.streamer, socket.assigns.channel) do
      {:ok, _changeset} ->
        ready_hosted = CostreamLookups.get_active_ready_hosted_costreams(socket.assigns.channel)
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Stopped co-stream successfully"))
          |> assign(:hosted, ready_hosted)
        }
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Unable to stop co-stream"))
        }
    end
  end

  def handle_event("join_costream", %{"id" => id}, socket) do
    costream_invite = CostreamInvites.get_by_id(id)
    case Costreams.join_costream(costream_invite, socket.assigns.streamer, socket.assigns.channel) do
      {:ok, _changeset} ->
        accepted_invites = CostreamLookups.get_accepted_and_joined_invites(socket.assigns.channel)
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Joined co-stream successfully"))
          |> assign(:invites, accepted_invites)
        }
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Unable to join co-stream"))
        }
    end
  end

  def handle_event("leave_costream", %{"id" => id}, socket) do
    costream_invite = CostreamInvites.get_by_id(id)
    case Costreams.leave_costream(costream_invite, socket.assigns.streamer, socket.assigns.channel) do
      {:ok, _changeset} ->
        accepted_invites = CostreamLookups.get_accepted_and_joined_invites(socket.assigns.channel)
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Left co-stream successfully"))
          |> assign(:invites, accepted_invites)
        }
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Unable to leave co-stream"))
        }
    end
  end
end
