defmodule GlimeshWeb.CostreamingLive.Index do
  use GlimeshWeb, :live_view

  alias Glimesh.Streams.{Channel, Costream, Costreams, CostreamBlockedChannels, CostreamInvites}
  alias Glimesh.ChannelLookups
  alias Glimesh.Costreams.CostreamLookups

  @impl true
  def mount(_params, session, socket) do
    user = Glimesh.Accounts.get_user_by_session_token(session["user_token"])
    channel = ChannelLookups.get_channel_for_user(user)
    costream_changeset = Channel.change_costreaming_changeset(channel)
    active_costreams = CostreamLookups.get_active_invited_costreams(channel)
    blocked_channels_changeset = CostreamBlockedChannels.changeset(%CostreamBlockedChannels{})
    blocked_channels = CostreamBlockedChannels.get_blocked_channels(channel)

    {:ok,
      socket
      |> assign(:user, user)
      |> assign(:channel, channel)
      |> assign(:costream_changeset, costream_changeset)
      |> assign(:active_costreams, active_costreams)
      |> assign(:manage_blocks, false)
      |> assign(:blocked_channels_changeset, blocked_channels_changeset)
      |> assign(:blocked_channels, blocked_channels)
      |> assign(:show_participants, false)
      |> assign(:show_participants_channels, [])
      |> assign(:show_participants_costream_name, "")
      |> put_page_title(format_page_title(gettext("Co-streaming Settings")))
    }
  end

  @impl true
  def handle_event("update_permissions", %{"channel" => %{"allow_costream" => allow_costream, "use_costream_tags" => use_costream_tags}}, socket) do
    current_user = socket.assigns.user
    channel = socket.assigns.channel

    with :ok <- Bodyguard.permit(Glimesh.Streams.Policy, :update_costream_permissions, current_user, channel) do
      case Channel.update_costreaming(channel, %{allow_costream: allow_costream, use_costream_tags: use_costream_tags}) do
        {:ok, channel} ->
          costream_changeset = Channel.change_costreaming_changeset(channel)
          {:noreply,
            socket
            |> put_flash(:costream_info, gettext("co-streaming permissions updated successfully"))
            |> assign(:channel, channel)
            |> assign(:costream_changeset, costream_changeset)
          }
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply,
            socket
            |> put_flash(:error, gettext("unable to update settings"))
            |> assign(:costream_changeset, changeset)
          }
      end
    end
  end

  def handle_event("toggle-manage-blocks", _params, socket) do
    {:noreply,
      socket
      |> assign(:manage_blocks, !socket.assigns.manage_blocks)
    }
  end

  def handle_event("add_blocked_channel", %{"costream_blocked_channels" => changes}, socket) do
    block_channel_name = changes["display_name"]
    block_channel = ChannelLookups.get_channel_for_display_name(block_channel_name, true, true)
    case Costreams.block_channel(socket.assigns.user, socket.assigns.channel, block_channel) do
      {:ok, _} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        blocked_channels = CostreamBlockedChannels.get_blocked_channels(socket.assigns.channel)
        {:noreply,
        socket
        |> assign(:active_costreams, active_costreams)
        |> assign(:blocked_channels, blocked_channels)
        |> assign(:blocked_channels_changeset, CostreamBlockedChannels.changeset(%CostreamBlockedChannels{}))
        }
      {:error, _changeset} ->
        {:noreply,
        socket
        |> put_flash(:error, gettext("unable to update blocked channels"))
        }
    end
  end

  def handle_event("unblock_channel", %{"id" => id}, socket) do
    case Costreams.unblock_channel(id, socket.assigns.user, socket.assigns.channel) do
      {:ok, _} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        blocked_channels = CostreamBlockedChannels.get_blocked_channels(socket.assigns.channel)
        {:noreply,
          socket
          |> assign(:active_costreams, active_costreams)
          |> assign(:blocked_channels, blocked_channels)
        }
      {:error, _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("unable to unblock channel"))
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

  def handle_event("accept_invite", %{"id" => id}, socket) do
    invite = CostreamInvites.get_by_id(id)
    case Costreams.accept_invite(socket.assigns.user, socket.assigns.channel, invite) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
          |> assign(:active_costreams, active_costreams)
          |> put_flash(:costream_info, gettext("Invitation accepted"))
        }
      {:error, _changeset} ->
        {:noreply, socket
          |> put_flash(:error, gettext("Error accepting invitation"))
        }
    end
  end

  def handle_event("decline_invite", %{"id" => id}, socket) do
    invite = CostreamInvites.get_by_id(id)
    case Costreams.decline_invite(socket.assigns.user, socket.assigns.channel, invite) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
          |> assign(:active_costreams, active_costreams)
          |> put_flash(:costream_info, gettext("Invitation declined"))
        }
      {:error, _changeset} ->
        {:noreply, socket
          |> put_flash(:error, gettext("Error declining invitation"))
        }
    end
  end

  def handle_event("join_costream", %{"id" => id}, socket) do
    invite = CostreamInvites.get_by_id(id)
    case Costreams.join_costream(invite, socket.assigns.user, socket.assigns.channel) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
          |> assign(:active_costreams, active_costreams)
          |> put_flash(:costream_info, gettext("Joined co-stream successfully"))
        }
      {:error, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
        |> assign(:active_costreams, active_costreams)
        |> put_flash(:error, gettext("Error joining co-stream"))
        }
    end
  end

  def handle_event("leave_costream", %{"id" => id}, socket) do
    invite = CostreamInvites.get_by_id(id)
    case Costreams.leave_costream(invite, socket.assigns.user, socket.assigns.channel) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
          |> assign(:active_costreams, active_costreams)
          |> put_flash(:costream_info, gettext("Left co-stream successfully"))
        }
      {:error, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
        |> assign(:active_costreams, active_costreams)
        |> put_flash(:error, gettext("Error leaving co-stream"))
        }
    end
  end

  def handle_event("block_invite", %{"id" => id}, socket) do
    invite = CostreamInvites.get_by_id(id)
    case Costreams.block_invite(socket.assigns.user, socket.assigns.channel, invite) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        blocked_channels_changeset = CostreamBlockedChannels.changeset(%CostreamBlockedChannels{})
        blocked_channels = CostreamBlockedChannels.get_blocked_channels(socket.assigns.channel)
        {:noreply, socket
          |> assign(:active_costreams, active_costreams)
          |> assign(:blocked_channels_changeset, blocked_channels_changeset)
          |> assign(:blocked_channels, blocked_channels)
          |> put_flash(:costream_info, gettext("Channel added to block list"))
        }
      {:error, _changeset} ->
        {:noreply, socket
          |> put_flash(:error, gettext("Error adding channel to block list"))
        }
    end
  end

  def handle_event("delete_invite", %{"id" => id}, socket) do
    {parsed_id, _} = Integer.parse(id)
    case CostreamInvites.guest_delete_invite(socket.assigns.user, socket.assigns.channel, parsed_id) do
      {:ok, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
          |> assign(:active_costreams, active_costreams)
          |> put_flash(:costream_info, gettext("Deleted invitation successfully"))
        }
      {:error, _changeset} ->
        active_costreams = CostreamLookups.get_active_invited_costreams(socket.assigns.channel)
        {:noreply, socket
        |> assign(:active_costreams, active_costreams)
        |> put_flash(:error, gettext("Error deleteing invitation"))
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
