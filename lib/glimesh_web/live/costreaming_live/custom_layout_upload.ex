defmodule GlimeshWeb.CostreamingLive.CustomLayoutUpload do
  use GlimeshWeb, :live_view

  alias Glimesh.ChannelLookups
  alias Glimesh.Streams.{Costreams, Costream}
  alias Glimesh.Costreams.CostreamCustomLayout

  @impl true
  def mount(_params, session, socket) do
    user = Glimesh.Accounts.get_user_by_session_token(session["user_token"])
    channel = ChannelLookups.get_channel_for_user(user)
    max_participants_options = Enum.to_list(2..Costream.get_max_participants)
    visible_participants_options = Enum.to_list(1..Costream.get_max_participants)

    {:ok,
      socket
      |> assign(:user, user)
      |> assign(:channel, channel)
      |> assign(:layout_changeset, CostreamCustomLayout.new_changeset(%CostreamCustomLayout{}))
      |> assign(:max_participants_options, max_participants_options)
      |> assign(:visible_participants_options, visible_participants_options)
      |> put_page_title(format_page_title(gettext("Co-streaming Custom Layout Upload")))
      |> allow_upload(:layout, accept: ~w(.css), max_file_size: 51_200, auto_upload: true)
    }
  end

  def error_to_string(:too_large), do: gettext("Too large")
  def error_to_string(:too_many_files), do: gettext("You have selected too many files")
  def error_to_string(:not_accepted), do: gettext("You have selected an unacceptable file type")

  @impl true
  def handle_event("save_details", %{"costream_custom_layout" => layout_changeset}, socket) do
    changeset = CostreamCustomLayout.changeset(%CostreamCustomLayout{channel: socket.assigns.channel}, layout_changeset)
    {:noreply,
      socket
      |> assign(:layout_changeset, changeset)
    }
  end

  def handle_event("validate_upload", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save_upload", _params, socket) do
    layout_changeset = socket.assigns.layout_changeset
    IO.inspect(layout_changeset, label: "layout changeset")
    attempted_uploads =
      consume_uploaded_entries(
        socket,
        :layout,
        &process_upload(layout_changeset, &1, &2)
      )

    {_, errored} = Enum.split_with(attempted_uploads, fn {status, _} -> status == :ok end)

    errors =
      Enum.map(errored, fn {:error, changeset} ->
        Ecto.Changeset.traverse_errors(changeset, fn _, field, {msg, _opts} ->
          "#{field} #{msg}"
        end)
      end)
      |> Enum.flat_map(fn input ->
        case input do
          %{layout: errors} -> errors
          %{original: _errors} -> [gettext("Please review the custom layout requirements before uploading.")]
          _ -> [gettext("Unexpected file input")]
        end
      end)

    if length(errors) > 0 do
      {:noreply,
       socket
       |> put_flash(:layout_error, Enum.join(errors, ". "))
       |> redirect(to: Routes.costreaming_settings_path(socket, :custom_layout_upload))}
    else
      {:noreply,
       socket
       |> put_flash(
         :layout_info,
         gettext("Successfully uploaded custom layout, pending review by the Core Team")
       )
       |> redirect(to: Routes.costreaming_settings_path(socket, :custom_layout_upload))}
    end
  end

  defp process_upload(layout_details_changeset, %{path: path}, entry) do
    IO.inspect(entry, label: "entry")
    if String.ends_with?(entry.client_name, ".css") or entry.client_type == "text/css" do
      details_changeset = CostreamCustomLayout.changeset(layout_details_changeset.data, layout_details_changeset.changes)
      IO.inspect(details_changeset, label: "details changeset")

      case Costreams.upload_custom_layout(details_changeset, %{original: path}) do
        {:ok, custom_layout} ->
          {:ok, {:ok, custom_layout}}
        {:error, changeset} ->
          {:postpone, {:error, changeset}}
      end
    else
      {:postpone, {:error, layout_details_changeset}}
    end
  end
end
