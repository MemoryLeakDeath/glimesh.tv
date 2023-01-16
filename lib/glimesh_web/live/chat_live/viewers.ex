defmodule GlimeshWeb.ChatLive.Viewers do
  use GlimeshWeb, :live_view

  alias Glimesh.ChatUserDetailsCache
  alias Glimesh.Accounts
  alias Glimesh.ChannelLookups
  alias Glimesh.Chat
  alias Glimesh.Streams
  alias Glimesh.Chat.Effects.Badges.{ChannelSubscriberBadge, ModeratorBadge, StreamerBadge}

  alias Phoenix.HTML.Tag


  @impl true
  def mount(_params, %{"channel_id" => channel_id} = session, socket) do
    if session["locale"], do: Gettext.put_locale(session["locale"])
    channel = ChannelLookups.get_channel!(channel_id)

    if session["user"] do
      user = session["user"]
      with :ok <- Bodyguard.permit(Glimesh.Chat.Policy, :view_viewer_list, user, channel) do
        {:ok, topic} = Streams.subscribe_to(:chatters, channel.id)
        {:ok,
        present_ids: present_ids,
        active: active_chatters,
        inactive: inactive_chatters} = get_chatters(topic, channel)

        {:ok,
          socket
          |> assign(:channel, channel)
          |> assign(:user, user)
          |> assign(:theme, Map.get(session, "site_theme", "dark"))
          |> assign(:permissions, Chat.get_moderator_permissions(channel, user))
          |> assign(:popped_out, Map.get(session, "popped_out", false))
          |> assign(:active_chatters, active_chatters)
          |> assign(:inactive_chatters, inactive_chatters)
          |> assign(:present_ids, present_ids)
        }
      else
        _ ->
          {:ok, redirect(socket, to: "/#{channel.user.username}/profile")}
      end
    else
      {:ok, redirect(socket, to: "/#{channel.user.username}/profile")}
    end
  end

  @impl true
  def handle_info(
        %{
          event: "presence_diff",
          topic: "streams:chatters:" <> _streamer = topic
        },
        socket
      ) do
    {:ok,
    present_ids: present_ids,
    active: active_chatters,
    inactive: inactive_chatters} = get_chatters(topic, socket.assigns.channel)

    {:noreply,
      socket
      |> assign(:active_chatters, active_chatters)
      |> assign(:inactive_chatters, inactive_chatters)
      |> assign(:present_ids, present_ids)
    }
  end

  @impl true
  def handle_event("short_timeout_user", %{"user" => to_ban_user}, socket) do
    Chat.short_timeout_user(
      socket.assigns.user,
      socket.assigns.channel,
      Accounts.get_by_username!(to_ban_user, true)
    )

    {:noreply, socket |> put_flash(:viewer_info, gettext("%{user} timed out for 5 minutes", user: to_ban_user))}
  end

  @impl true
  def handle_event("long_timeout_user", %{"user" => to_ban_user}, socket) do
    Chat.long_timeout_user(
      socket.assigns.user,
      socket.assigns.channel,
      Accounts.get_by_username!(to_ban_user, true)
    )

    {:noreply, socket |> put_flash(:viewer_info, gettext("%{user} timed out for 15 minutes", user: to_ban_user))}
  end

  @impl true
  def handle_event("ban_user", %{"user" => to_ban_user}, socket) do
    Chat.ban_user(
      socket.assigns.user,
      socket.assigns.channel,
      Accounts.get_by_username!(to_ban_user, true)
    )

    {:noreply, socket |> put_flash(:viewer_info, gettext("%{user} banned", user: to_ban_user))}
  end

  def render_username_and_avatar(user, user_metadata) do
    [render_avatar(user, user_metadata), " ", render_username(user, user_metadata)]
  end

  def render_avatar(user, user_metadata) do
    tags =
      cond do
        user_metadata[:admin] ->
          [class: "avatar-ring platform-admin-ring"]

        not is_nil(user_metadata[:platform_founder]) ->
          [class: "avatar-ring avatar-animated-ring platform-founder-ring"]

        not is_nil(user_metadata[:platform_supporter]) ->
          [class: "avatar-ring platform-supporter-ring"]

        true ->
          [class: "avatar-ring"]
      end

    Tag.content_tag(
      :div,
      Tag.img_tag(
        user[:avatar],
        height: "20",
        width: "20",
        alt: user[:displayname]
      ),
      tags
    )
  end

  def render_username(user, user_metadata) do
    tags =
      cond do
        user_metadata[:admin] ->
          [
            "data-toggle": "tooltip",
            title: gettext("Glimesh Staff")
          ]

        user_metadata[:gct] ->
          [
            "data-toggle": "tooltip",
            title: gettext("Core Team")
          ]

        user_metadata[:community_champion] ->
          [
            "data-toggle": "tooltip",
            title: gettext("Community Champion")
          ]

        not is_nil(user_metadata[:platform_founder]) ->
          [
            "data-toggle": "tooltip",
            title: gettext("Glimesh Gold Supporter Subscriber")
          ]

        not is_nil(user_metadata[:platform_supporter]) ->
          [
            "data-toggle": "tooltip",
            title: gettext("Glimesh Supporter Subscriber")
          ]

        true ->
          []
      end

    color_class = [class: get_username_color(user_metadata)]

    default_tags = [
      to: Routes.user_profile_path(GlimeshWeb.Endpoint, :index, user[:username]),
      target: "_blank"
    ]

    Phoenix.HTML.Link.link(user[:displayname], default_tags ++ color_class ++ tags)
  end

  def render_channel_badge(user, user_metadata) do
    cond do
      user[:streamer] ->
        StreamerBadge.render()
      not is_nil(user_metadata[:channel_moderator]) and not is_nil(user_metadata[:channel_subscriber]) ->
        [ModeratorBadge.render(), " ", ChannelSubscriberBadge.render()]
      not is_nil(user_metadata[:channel_moderator]) ->
        ModeratorBadge.render()
      not is_nil(user_metadata[:channel_subscriber]) ->
        ChannelSubscriberBadge.render()
      true ->
        ""
    end
  end

  defp get_chatters(topic, channel) do
    active_chatters = ChatUserDetailsCache.get_active_chatters(channel)
    inactive_chatters = ChatUserDetailsCache.get_inactive_chatters(channel)

    all_present = Glimesh.Presence.list_presences(topic)
    all_present_user_ids = Enum.map(all_present, fn item ->
      item[:user_id]
    end)

    {:ok, present_ids: all_present_user_ids, active: active_chatters, inactive: inactive_chatters}
  end

  defp get_username_color(user_metadata, default \\ "text-color-link") do
    cond do
      user_metadata[:admin] -> "text-danger"
      user_metadata[:gct] -> "text-primary"
      user_metadata[:community_champion] -> "text-success"
      user_metadata[:events_team] -> "EventsTeam_Font"
      not is_nil(user_metadata[:platform_founder]) -> "text-warning"
      true -> default
    end
  end
end
