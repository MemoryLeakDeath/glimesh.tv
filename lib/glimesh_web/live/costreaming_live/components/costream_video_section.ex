defmodule GlimeshWeb.CostreamingLive.Components.CostreamVideoSection do
  use GlimeshWeb, :live_view

  alias Glimesh.Presence
  alias Glimesh.Streams
  alias Glimesh.Streams.{Channel, Costream, CostreamInvites}

  @impl Phoenix.LiveView
  def render(assigns) do
    render_shadow_root(assigns)
  end

  defp render_shadow_root(assigns) do
    costream_section = Phoenix.HTML.javascript_escape(Phoenix.HTML.raw(Phoenix.HTML.Safe.to_iodata(render_costream_section(assigns))))
    hook_wrapper_section = Phoenix.HTML.raw(Phoenix.HTML.Safe.to_iodata(render_hook_wrapper(assigns)))
    ~H"""
        <script language="javascript">
          class CostreamVideoPanel extends HTMLElement {
            constructor() {
              super();
              this.attachShadow({mode: 'open'});
              this.shadowRoot.innerHTML = "<%= costream_section %>";
            }
          }
          customElements.define('costream-panel', CostreamVideoPanel);
        </script>
        <%= hook_wrapper_section %>
        <costream-panel id="costream-panel"></costream-panel>
    """
  end

  defp render_hook_wrapper(assigns) do
    ~H"""
      <div
        id={"costream-hook-wrapper"}
        class="d-none"
        phx-hook="ShadowDomSupport"
        data-shadow-root-element="costream-panel"
      ></div>
    """
  end

  defp render_costream_section(assigns) do
    ~H"""
      <link rel="stylesheet" href={Routes.static_path(GlimeshWeb.Endpoint, "/css/#{@layout_filename}")}/>
      <link rel="stylesheet" href={Routes.static_path(GlimeshWeb.Endpoint, "/css/costream-includes.css")}/>
      <div id="costream-video-container" class={
        [
          "#{@costream.layout_type}",
          if(@ultrawide, do: "content21by9", else: "content16by9")
        ]
      } phx-hook="CostreamCarousel" data-prev-button=".previousCostreamButton" data-next-button=".nextCostreamButton">
      <!-- previous button -->
        <img id="previous-costream-button-image" class="previousCostreamButtonImage carouselnav">
        <button id="previous-costream-button" class="previousCostreamButton carouselnav" title={gettext("Previous")}>
          <i class="fas fa-chevron-left"></i>
        </button>
        <div id="costream-video-grid" class="costreamVideoGrid">
          <!-- host video -->
            <%= render_host_section(assigns) %>
          <!-- *************** -->
          <!-- Main Channel video (if different from host) -->
            <%= render_main_channel_section(assigns) %>
          <!-- ************** -->
          <!-- guest videos -->
            <%= render_guest_section(assigns) %>
          <!-- ***************** -->
        </div>
      <!-- next button -->
        <img id="next-costream-button-image" class="nextCostreamButtonImage carouselnav">
        <button id="next-costream-button" class="nextCostreamButton carouselnav" title={gettext("Next")}>
          <i class="fas fa-chevron-right"></i>
        </button>
    </div>
    """
  end

  defp render_host_section(assigns) do
    ~H"""
      <%= if @costream_host != nil do %>
      <div
        id={"costream-section-#{@costream_host.user.username}"}
        class=
          {
            if @costream_visible_ids[:"#{@costream_host.id}"] != nil do
              "costream-visible visible-slot-#{@costream_visible_ids[:"#{@costream_host.id}"]}"
            else
              "costream-hidden hidden-slot-#{@costream_hidden_ids[:"#{@costream_host.id}"]}"
            end
          }
        style="display: flex"
      >
        <video
        id={"video-player-#{@costream_host.user.username}"}
        class={
          [
            "costream-host costream-user-#{@costream_host.user.username}",
            if(@channel_id == @costream_host.id, do: "costream-main")
          ]
        }
        phx-hook="FtlVideo"
        controls
        playsinline
        poster={@costream_host_poster}
        data-muted={if(@channel_id == @costream_host.id, do: @muted, else: true)}
        data-channel-id={@costream_host.id}
        data-avatar={Glimesh.Avatar.url({@costream_host.user.avatar, @costream_host.user}, :original)}
        data-display-name={@costream_host.user.displayname}
        >
        </video>
        <div
        id={"costream-video-overlay-#{@costream_host.user.username}"}
        class={
          [
            "costream-overlay costream-user-#{@costream_host.user.username}"
          ]
        }
        data-avatar={Glimesh.Avatar.url({@costream_host.user.avatar, @costream_host.user}, :original)}
        data-display-name={@costream_host.user.displayname}
        >
          <img
          src={Glimesh.Avatar.url({@costream_host.user.avatar, @costream_host.user}, :original)}
          >
          <span><%= @costream_host.user.displayname %></span>
        </div>
        <div
        id={"costream-swap-div-#{@costream_host.user.username}"}
        class={
          [
            "costream-swap costream-user-#{@costream_host.user.username}"
          ]
        }
        >
          <button
            id={"costream-swap-button-#{@costream_host.user.username}"}
            class={"btn btn-primary"}
            phx-hook="CostreamSwapper"
            data-slot={@costream_visible_ids[:"#{@costream_host.id}"]}
            data-slot-hidden="false"
            data-username={@costream_host.user.username}
          ><i class="fas fa-exchange-alt fa-3x"></i></button>
        </div>
      </div>
    <% end %>
    """
  end

  defp render_main_channel_section(assigns) do
    ~H"""
      <%= if @costream_main.id != @costream_host.id do %>
      <div id={"costream-section-#{@costream_main.user.username}"} class={"costream-visible visible-slot-#{@costream_visible_ids[:"#{@costream_main.id}"]}"} style="display: flex">
        <video
        id={"video-player-#{@costream_main.user.username}"}
        class={
          [
            "costream-main costream-user-#{@costream_main.user.username}"
          ]
        }
        phx-hook="FtlVideo"
        controls
        playsinline
        poster={@costream_main_poster}
        data-muted={@muted}
        data-channel-id={@costream_main.id}
        data-avatar={Glimesh.Avatar.url({@costream_main.user.avatar, @costream_main.user}, :original)}
        data-display-name={@costream_main.user.displayname}
        >
        </video>
        <div
        id={"costream-video-overlay-#{@costream_main.user.username}"}
        class={
          [
            "costream-overlay costream-user-#{@costream_main.user.username}"
          ]
        }
        data-avatar={Glimesh.Avatar.url({@costream_main.user.avatar, @costream_main.user}, :original)}
        data-display-name={@costream_main.user.displayname}
        >
          <img
          src={Glimesh.Avatar.url({@costream_main.user.avatar, @costream_main.user}, :original)}
          >
          <span><%= @costream_main.user.displayname %></span>
        </div>
        <div
          id={"costream-swap-div-#{@costream_main.user.username}"}
          class={
            [
              "costream-swap costream-user-#{@costream_main.user.username}"
            ]
          }
          >
          <button
            id={"costream-swap-button-#{@costream_main.user.username}"}
            class={"btn btn-primary"}
            phx-hook="CostreamSwapper"
            data-slot={@costream_visible_ids[:"#{@costream_main.id}"]}
            data-slot-hidden="false"
            data-username={@costream_main.user.username}
          ><i class="fas fa-exchange-alt fa-3x"></i></button>
        </div>
        <div id="video-loading-container" class="">
          <div class="lds-ring">
            <div></div>
            <div></div>
            <div></div>
            <div></div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  defp render_guest_section(assigns) do
    ~H"""
      <%= for {participant, video_index} <- Enum.with_index(@costream_guests, 3) do %>
      <div
        id={"costream-section-#{participant.channel.user.username}"}
        class={
          [
            if Enum.count(@costream_visible_guests, fn g -> g.channel_id == participant.channel_id end) > 0 do
              "costream-visible visible-slot-#{@costream_visible_ids[:"#{participant.channel_id}"]}"
            else
              "costream-hidden hidden-slot-#{@costream_hidden_ids[:"#{participant.channel_id}"]}"
            end
          ]
        }
        style={
          if Enum.count(@costream_visible_guests, fn g -> g.channel_id == participant.channel_id end) > 0 do
            "display: flex"
          else
            "display: flex; visibility: hidden;"
          end
          }>
        <video
          id={"video-player-#{participant.channel.user.username}"}
          class={
            [
              "costream-guest",
              "costream-user-#{participant.channel.user.username}"
            ]
          }
          phx-hook="FtlVideo"
          controls
          playsinline
          poster={Map.get(@costream_guest_posters, "#{participant.channel.id}")}
          data-muted={true}
          data-channel-id={participant.channel_id}
          data-costream-position={"#{video_index}"}
          data-avatar={Glimesh.Avatar.url({participant.channel.user.avatar, participant.channel.user}, :original)}
          data-display-name={participant.channel.user.displayname}
          >
        </video>
        <div
        id={"costream-video-overlay-#{participant.channel.user.username}"}
        class={
          [
            "costream-overlay",
            "costream-user-#{participant.channel.user.username}",
            "costream-#{video_index}"
          ]
        }
        data-avatar={Glimesh.Avatar.url({participant.channel.user.avatar, participant.channel.user}, :original)}
        data-display-name={participant.channel.user.displayname}
        data-costream-position={"#{video_index}"}
        >
          <img
          src={Glimesh.Avatar.url({participant.channel.user.avatar, participant.channel.user}, :original)}
          >
          <span><%= participant.channel.user.displayname %></span>
        </div>
        <div
        id={"costream-swap-div-#{participant.channel.user.username}"}
        class={
          [
            "costream-swap costream-user-#{participant.channel.user.username}"
          ]
        }
        >
          <button
            id={"costream-swap-button-#{participant.channel.user.username}"}
            class={"btn btn-primary"}
            phx-hook="CostreamSwapper"
            data-slot={
              if Enum.count(@costream_visible_guests, fn g -> g.channel_id == participant.channel_id end) > 0 do
                @costream_visible_ids[:"#{participant.channel.id}"]
              else
                @costream_hidden_ids[:"#{participant.channel.id}"]
              end
            }
            data-slot-hidden={
              if Enum.count(@costream_visible_guests, fn g -> g.channel_id == participant.channel_id end) > 0 do
                "false"
              else
                "true"
              end
            }
            data-username={participant.channel.user.username}
          ><i class="fas fa-exchange-alt fa-3x"></i></button>
        </div>
      </div>
    <% end %>
  """
  end

  defp call_render_costream_section_again(socket) do
    Phoenix.HTML.safe_to_string(Phoenix.HTML.raw(Phoenix.HTML.Safe.to_iodata(render_costream_section(socket.assigns))))
  end

  defp get_visible_channel_slots(costream_host, costream_main, costream_guests, default_visible) do
    # costream host and main channel always default to visible, figure out
    # how many guests should be visible if host and main channel are the same
    visible_guest_count =
      if costream_main.id == costream_host.id do
        default_visible - 1
      else
        default_visible - 2
      end
    costream_visible_guests = if visible_guest_count > 0, do: Enum.take_random(costream_guests, visible_guest_count), else: []
    costream_hidden_guests = Enum.reject(costream_guests, fn x -> Enum.member?(costream_visible_guests, x) end)
    costream_hidden_guests = if visible_guest_count < 0, do: Enum.concat(costream_hidden_guests, [costream_host]), else: costream_hidden_guests
    combined_visible = if visible_guest_count >= 0 and costream_main.id != costream_host.id, do: Enum.concat([[costream_main], [costream_host], costream_visible_guests]), else: Enum.concat([costream_main], costream_visible_guests)
    visible_channel_ids = Enum.with_index(combined_visible, fn element, index ->
      case element do
        %Channel{} ->
          {String.to_atom("#{element.id}"), index + 1}
        %CostreamInvites{} ->
          {String.to_atom("#{element.channel_id}"), index + 1}
      end
    end)
    hidden_channel_ids = Enum.with_index(costream_hidden_guests, fn element, index ->
      case element do
        %Channel{} ->
          {String.to_atom("#{element.id}"), index + 1}
        %CostreamInvites{} ->
          {String.to_atom("#{element.channel_id}"), index + 1}
      end
    end)

    %{
      visible_ids: visible_channel_ids,
      visible_guests: costream_visible_guests,
      hidden_guests: costream_hidden_guests,
      hidden_ids: hidden_channel_ids
    }
  end

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    channel_id = session["channel_id"]
    costream = Costream.get_by_id(session["costream_id"])
    costream_guests = CostreamInvites.get_joined_invites(session["costream_id"])
    costream_host = Enum.at(costream_guests, 0).costream.host
    {:ok,
      %{
        :channel_video => costream_main,
        :poster => main_poster
      }
    } = get_main_channel_and_poster(channel_id, costream_host, costream_guests)
    costream_guests = Enum.reject(costream_guests, fn c -> c.channel_id == costream_main.id end)
    {:ok,
      %{
        :guest_posters => guest_posters,
        :host_poster => host_poster
      }
    } = get_stream_thumbnails(costream_guests, costream_host)
    costream_types = Costream.list_costream_types()
    layout_filename = costream_types[costream.layout_type][:layout]

    default_visible = costream_types[costream.layout_type][:visible]
    %{
      :visible_ids => visible_ids,
      :visible_guests => costream_visible_guests,
      :hidden_guests => costream_hidden_guests,
      :hidden_ids => hidden_ids
    } = get_visible_channel_slots(costream_host, costream_main, costream_guests, default_visible)
    if connected?(socket) do
      # Wait until the socket connection is ready to load the stream
      Process.send(self(), :load_stream, [])
    end

    {:ok,
      socket
      |> assign(:channel_id, channel_id)
      |> assign(:muted, Map.get(session, "muted", false))
      |> assign(:unique_user, session["unique_user"])
      |> assign(:country, session["country"])
      |> assign(:costream_guests, costream_guests)
      |> assign(:costream_host, costream_host)
      |> assign(:ultrawide, session["ultrawide"])
      |> assign(:costream_guest_posters, guest_posters)
      |> assign(:costream_host_poster, host_poster)
      |> assign(:costream_main, costream_main)
      |> assign(:costream_main_poster, main_poster)
      |> assign(:costream_visible_guests, costream_visible_guests)
      |> assign(:costream_visible_ids, visible_ids)
      |> assign(:costream_max_visible, default_visible)
      |> assign(:costream_hidden_guests, costream_hidden_guests)
      |> assign(:costream_hidden_ids, hidden_ids)
      |> assign(:costream, costream)
      |> assign(:layout_filename, layout_filename)
    }
  end

  defp get_main_channel_and_poster(channel_id, costream_host, costream_guests) do
    channel_video =
      if costream_host.id == channel_id do
        costream_host
      else
        guest = Enum.find(costream_guests, fn c -> c.channel_id == channel_id end)
        if guest != nil, do: guest.channel, else: nil
      end
    poster =
      if costream_host.id == channel_id do
        get_host_poster(costream_host)
      else
        get_main_poster(costream_guests, channel_id)
      end
    {:ok,
      %{
        channel_video: channel_video,
        poster: poster
      }
    }
  end

  defp get_stream_thumbnails(guests, host) do
    {:ok,
      %{
        guest_posters: get_guest_posters(guests),
        host_poster: get_host_poster(host)
      }
    }
  end

  defp get_host_poster(host) do
    case host.stream do
      %Glimesh.Streams.Stream{} = stream ->
        Glimesh.StreamThumbnail.url({stream.thumbnail, stream}, :original)

      _ ->
        Glimesh.ChannelPoster.url({host.poster, host}, :original)
    end
  end

  defp get_guest_posters(guests) do
    guest_posters =
      for(guest <- guests) do
        case guest.channel.stream do
          %Glimesh.Streams.Stream{} = stream ->
            %{"#{guest.channel.id}" => Glimesh.StreamThumbnail.url({stream.thumbnail, stream}, :original)}

          _ ->
            %{"#{guest.channel.id}" => Glimesh.ChannelPoster.url({guest.channel.poster, guest.channel}, :original)}
        end
      end
    Enum.reduce(guest_posters, fn first, second ->
      Map.merge(first, second)
    end)
  end

  defp get_main_poster(guests, channel_id) do
    main_channel = Enum.find(guests, fn c -> c.channel.id == channel_id end)
    case main_channel.channel.stream do
      %Glimesh.Streams.Stream{} = stream ->
        Glimesh.StreamThumbnail.url({stream.thumbnail, stream}, :original)
      _ ->
        Glimesh.ChannelPoster.url({main_channel.channel.poster, main_channel.channel}, :original)
    end
  end

  @impl Phoenix.LiveView
  def handle_info(:load_stream, socket) do
    case Glimesh.Janus.get_closest_edge_location(socket.assigns.country) do
      %Glimesh.Janus.EdgeRoute{id: janus_edge_id, url: janus_url, hostname: janus_hostname} ->
        Presence.track_presence(
          self(),
          Streams.get_subscribe_topic(:viewers, socket.assigns.channel_id),
          socket.assigns.unique_user,
          %{
            janus_edge_id: janus_edge_id
          }
        )

        Process.send(socket.parent_pid, :remove_packet_warning, [])

        # for co-streams we need to load multiple videos, so push those events
        socket = push_event(socket, "load_video", %{
          janus_url: janus_url,
          channel_id: socket.assigns.costream_host.id
        })
        socket = push_event(socket, "load_video", %{
          janus_url: janus_url,
          channel_id: socket.assigns.costream_main.id
        })
        socket = Enum.reduce(socket.assigns.costream_guests, socket, fn guest, acc_socket ->
          push_event(acc_socket, "load_video", %{
            janus_url: janus_url,
            channel_id: guest.channel_id
          })
        end)

        {:noreply,
         socket
         |> assign(:janus_url, janus_url)
         |> assign(:janus_hostname, janus_hostname)}

      _ ->
        # In the event we can't find an edge, something is real wrong
        {:noreply,
         socket
         |> assign(:player_error, "Unable to find edge video location, we'll be back soon!")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("lost_packets", %{"uplink" => _uplink, "lostPackets" => lost_packets}, socket)
      when is_integer(lost_packets) do
    # Send packet loss up the chain so other components can handle it
    Process.send(socket.parent_pid, {:debug, :packet_loss, lost_packets}, [])

    {:noreply, socket}
  end

  def handle_event("ultrawide", %{"enabled" => enabled}, socket) do
    socket = assign(socket, :ultrawide, enabled)
    html = call_render_costream_section_again(socket)
    {:noreply,
      socket
      |> push_event("populateShadowRoot", %{html: html})
    }
  end

  def handle_event("lost_packets", _, socket) do
    {:noreply, socket}
  end

end
