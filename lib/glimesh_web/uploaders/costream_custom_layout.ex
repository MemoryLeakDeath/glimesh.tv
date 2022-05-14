defmodule Glimesh.Uploaders.CostreamCustomLayout do
  @moduledoc false

  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @max_file_size 51_200

  def acl(:original, _), do: :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    size_passes = file_size(file) <= @max_file_size

    size_passes
  end

  # Override the persisted filenames:
  def filename(_version, {_file, %Glimesh.Costreams.CostreamCustomLayout{} = layout}) do
    "#{layout.id}.css"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    "uploads/costream-layouts"
  end

  def s3_object_headers(_version, {_file, _scope}) do
    [
      cache_control: "public, max-age=604800",
      content_type: "text/css"
    ]
  end

  defp file_size(%Waffle.File{} = file) do
    File.stat!(file.path) |> Map.get(:size)
  end
end
