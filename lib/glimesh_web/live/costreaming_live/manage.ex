defmodule GlimeshWeb.CostreamingLive.Manage do
  use GlimeshWeb, :live_view

  alias Glimesh.Streams.Costream
  alias Glimesh.Streams.CostreamInvites
  alias Glimesh.Streams.Tag
  alias Glimesh.ChannelLookups
  alias Glimesh.ChannelCategories
  alias Glimesh.Costreams.CostreamLookups

  def get_common_assigns(session, socket) do
    page_action = session["live_action"]
    user = Glimesh.Accounts.get_user_by_session_token(session["user_token"])
    channel = ChannelLookups.get_channel_for_user_id(user.id)
    categories = ChannelCategories.list_categories_for_select()
    category = channel.category
    subcategory_label = ChannelCategories.get_subcategory_label(category)
    subcategory_placeholder = ChannelCategories.get_subcategory_select_label_description(category)
    subcategory_attribution = ChannelCategories.get_subcategory_attribution(category)
    layout_options = Enum.map(Costream.list_costream_types(), fn {k, v} -> {gettext("%{key}", key: k), v[:type]} end)
    max_participants_options = Enum.to_list(2..6)
    existing_subcategory = if(channel.subcategory, do: channel.subcategory.name, else: "")
    existing_tags = Enum.map_join(channel.tags, ", ", fn tag -> tag.name end)

    socket
    |> assign(:page_action, page_action)
    |> assign(:user, user)
    |> assign(:channel, channel)
    |> assign(:categories, categories)
    |> assign(:category, category)
    |> assign(:subcategory_label, subcategory_label)
    |> assign(:subcategory_placeholder, subcategory_placeholder)
    |> assign(:subcategory_attribution, subcategory_attribution)
    |> assign(:matches, [])
    |> assign(:add_channel, "")
    |> assign(:add_channel_selected_value, "")
    |> assign(:layout_options, layout_options)
    |> assign(:max_participants_options, max_participants_options)
    |> assign(:existing_subcategory, existing_subcategory)
    |> assign(:existing_tags, existing_tags)
end

  @impl true
  def mount(_params, %{"live_action" => "create"} = session, socket) do
    socket = get_common_assigns(session, socket)
    costream_changeset = Costream.changeset(%Costream{}, %{name: gettext("My co-stream"), host_id: socket.assigns[:channel].id})

    {:ok,
      socket
      |> put_page_title(format_page_title(gettext("Create new co-stream")))
      |> assign(:costream_changeset, costream_changeset)
    }
  end

  @impl true
  def mount(_params, %{"live_action" => "edit"} = session, socket) do
    socket = get_common_assigns(session, socket)
    costream = session["edit_costream"]
    costream_changeset = Costream.changeset(costream)
    existing_subcategory = if costream.subcategory != nil, do: costream.subcategory.name, else: ""
    existing_tags = Enum.map_join(Tag.get_tags(costream.category_tags), ", ", fn tag -> tag.name end)
    existing_invites = CostreamLookups.get_active_invites(costream.id, socket.assigns.channel.id)

    {:ok,
      socket
      |> put_page_title(format_page_title(gettext("Manage co-stream")))
      |> assign(:saved_costream, costream)
      |> assign(:costream_changeset, costream_changeset)
      |> assign(:edit_id, costream.id)
      |> assign(:existing_subcategory, existing_subcategory)
      |> assign(:existing_tags, existing_tags)
      |> assign(:existing_invites, existing_invites)
      }
  end

  def handle_event("update_details", %{"_target" => ["costream", "layout_type"], "costream" => costream_changeset}, socket) do
    layout_options = Costream.list_costream_types()
    layout_type = costream_changeset["layout_type"]
    max_participants = Enum.find_value(layout_options, fn({_k, v}) -> if v[:type] === layout_type, do: v[:max] end)
    max_participants_options = Enum.to_list(2..max_participants)
    changeset = Costream.changeset(%Costream{}, costream_changeset)

    {:noreply,
      socket
      |> assign(:max_participants_options, max_participants_options)
      |> assign(:costream_changeset, changeset)
    }
  end

  def handle_event(
        "update_details",
        %{"_target" => ["costream", "category_id"], "costream" => costream_changeset},
        socket
      ) do
    category = ChannelCategories.get_category_by_id!(costream_changeset["category_id"])
    changeset = Costream.changeset(%Costream{}, costream_changeset)
    {:noreply,
     socket
     |> assign(:category, category)
     |> assign(:costream_changeset, changeset)
     |> assign(
       :subcategory_label,
       ChannelCategories.get_subcategory_label(category)
     )
     |> assign(
       :subcategory_placeholder,
       ChannelCategories.get_subcategory_select_label_description(category)
     )
     |> assign(
       :subcategory_attribution,
       Glimesh.ChannelCategories.get_subcategory_attribution(category)
     )
     |> assign(:existing_subcategory, "")
     |> assign(:existing_tags, "")
     |> assign(:current_category_id, costream_changeset["category_id"])
    }
  end

  def handle_event("update_details", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("create_costream", %{"costream" => costream_changeset}, socket) do
    case Costream.create_costream(%Costream{host_id: socket.assigns[:channel].id}, costream_changeset) do
      {:ok, costream} ->
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Created co-stream successfully"))
          |> redirect(to: Routes.costreaming_settings_path(socket, :edit, costream.id))
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:costream_changeset, changeset)}
    end
  end

  def handle_event("update_costream", %{"costream" => costream_changeset}, socket) do
    case Costream.update_costream(%Costream{id: socket.assigns[:edit_id], host_id: socket.assigns[:channel].id}, costream_changeset) do
      {:ok, costream} ->
        {:noreply,
          socket
          |> put_flash(:costream_info, gettext("Updated co-stream successfully"))
          |> redirect(to: Routes.costreaming_settings_path(socket, :edit, costream.id))
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:costream_changeset, changeset)}
    end
  end

  def handle_event("delete_invite", %{"invite-id" => id, "costream-id" => costream_id}, socket) do
    {parsed_id, _} = Integer.parse(id)
    costream = Costream.get_by_id(costream_id)
    case CostreamInvites.host_delete_invite(socket.assigns.user, socket.assigns.channel, costream, parsed_id) do
      {:ok, _} ->
        existing_invites = CostreamLookups.get_active_invites(costream.id, socket.assigns.channel.id)
        {:noreply,
          socket
          |> assign(:existing_invites, existing_invites)
          |> put_flash(:costream_info, gettext("Cancelled invitation successfully"))
        }
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Unable to cancel invitation"))
        }
    end
  end

  @impl true
  def handle_event("suggest", %{"_target" => ["add_channel"], "add_channel" => add_channel}, socket) do
    matches = search_for_channels(socket.assigns.saved_costream, add_channel, socket.assigns.user)

    {:noreply,
     assign(socket, matches: matches, add_channel: add_channel, add_channel_selected_value: "")}
  end

  def handle_event("suggest", %{"_target" => ["nothing", "type"], "nothing" => guest_type}, socket) do
    {:noreply,
      assign(socket, nothing: guest_type)}
  end

  @impl true
  def handle_event(
        "add_channel_selection_made",
        %{"user_id" => _user_id, "username" => username, "channel_id" => channel_id},
        socket
      ) do
    {:noreply,
     socket
     |> assign(add_channel_selected_value: channel_id)
     |> assign(add_channel: username)}
  end

  @impl true
  def handle_event(
        "invite_channel",
        %{"add_channel" => add_channel, "nothing" => %{"type" => type}},
        socket
      ) do
    invite_channel = Enum.at(search_for_channels(socket.assigns.saved_costream, add_channel, socket.assigns.user), 0)
    saved_costream = socket.assigns.saved_costream

    case CostreamInvites.create_invite(socket.assigns.user, invite_channel, saved_costream, %{type: type}) do
      {:ok, _} ->
        {:noreply,
          socket
          |> assign(:matches, [])
          |> assign(:add_channel, "")
          |> assign(:add_channel_selected_value, "")
          |> put_flash(:costream_info, gettext("Invitation sent"))
          |> redirect(to: Routes.costreaming_settings_path(socket, :edit, saved_costream.id))
        }
      {:error, _costream_invite} ->
        {:noreply,
          socket
          |> assign(:matches, [])
          |> assign(:add_channel_selected_value, "")
          |> put_flash(:error, gettext("Unable to invite channel"))
        }

    end
  end

  defp search_for_channels(costream, term, host_user) do
    CostreamLookups.search_for_possible_costreamers(costream, term, host_user)
  end

  def search_categories(query, socket) do
    ChannelCategories.tagify_search_for_subcategories(socket.assigns.category, query)
  end

  def search_tags(query, socket) do
    ChannelCategories.tagify_search_for_tags(socket.assigns.category, query)
  end
end
