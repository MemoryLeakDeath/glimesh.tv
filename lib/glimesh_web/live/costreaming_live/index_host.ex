defmodule GlimeshWeb.CostreamingLive.IndexHost do
  use GlimeshWeb, :live_view

  alias Glimesh.Streams.{Channel, Costream, Costreams, CostreamInvites}
  alias Glimesh.ChannelLookups
  alias Glimesh.Costreams.CostreamLookups

  @impl true
  def mount(_params, session, socket) do
    user = Glimesh.Accounts.get_user_by_session_token(session["user_token"])
    channel = ChannelLookups.get_channel_for_user(user)
    costream_changeset = Channel.change_costreaming_changeset(channel)
    active_costreams = CostreamLookups.get_active_hosted_costreams(channel)

    {:ok,
      socket
      |> assign(:user, user)
      |> assign(:channel, channel)
      |> assign(:costream_changeset, costream_changeset)
      |> assign(:active_costreams, active_costreams)
      |> assign(:show_participants, false)
      |> assign(:show_participants_channels, [])
      |> assign(:show_participants_costream_name, "")
      |> put_page_title(format_page_title(gettext("Hosted Co-streams")))
    }
  end

  @impl true
  def handle_event("delete_costream", %{"id" => id}, socket) do
    {parsed_id, _} = Integer.parse(id)
    case Costreams.delete_costream(parsed_id, socket.assigns.user, socket.assigns.channel) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_hosted_costreams(socket.assigns.channel)
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Deleted co-stream successfully"))
          |> assign(:active_costreams, active_costreams)
        }
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Unable to delete co-stream"))
        }
    end
  end

  def handle_event("toggle-show-participants", %{"id" => id}, socket) do
    show_participants = !socket.assigns.show_participants
    if show_participants == true do
      show_participants(id, socket)
    else
      hide_participants(socket)
    end
  end

  def handle_event("toggle-show-participants", _params, socket) do
    hide_participants(socket)
  end

  def handle_event("start_costream", %{"id" => id}, socket) do
    costream = Costream.get_by_id(id)
    case Costreams.start_costream(costream, socket.assigns.user, socket.assigns.channel) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_hosted_costreams(socket.assigns.channel)
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Started co-stream successfully"))
          |> assign(:active_costreams, active_costreams)
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
    case Costreams.stop_costream(costream, socket.assigns.user, socket.assigns.channel) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_hosted_costreams(socket.assigns.channel)
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Stopped co-stream successfully"))
          |> assign(:active_costreams, active_costreams)
        }
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Unable to stop co-stream"))
        }
    end
  end

  defp show_participants(id, socket) do
    {parsed_id, _} = Integer.parse(id)
    costream = Costream.get_by_id(parsed_id)
    participants =
      if socket.assigns.channel.id == costream.host_id do
        costream.guests
      else
        CostreamInvites.get_accepted_invites(costream)
      end
    {:noreply,
      socket
      |> assign(:show_participants, true)
      |> assign(:show_participants_channels, participants)
      |> assign(:show_participants_costream_name, costream.name)
    }
  end

  defp hide_participants(socket) do
    {:noreply,
      socket
      |> assign(:show_participants, false)
      |> assign(:show_participants_channels, [])
      |> assign(:show_participants_costream_name, "")
    }
  end
end
