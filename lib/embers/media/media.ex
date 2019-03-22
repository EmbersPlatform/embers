defmodule Embers.Media do
  alias Embers.Media.MediaItem
  alias Embers.Repo
  alias Embers.Uploads
  alias Embers.Thumbnex

  import Ecto.Query

  require Logger

  @supported_formats ~w(jpg jpeg png gif webm mp4)

  def get(id) do
    MediaItem |> where([m], m.id == ^id) |> Repo.one()
  end

  def upload(file, owner) do
    name = Ecto.UUID.generate()

    dest_path = "media/#{name}"

    with {:ok, processed_file} <- process_file(file),
         ext <- get_file_ext(processed_file),
         {:ok, res} <-
           Uploads.upload(
             processed_file.path,
             get_bucket(),
             dest_path <> ".#{ext}"
           ),
         {:ok, preview} <-
           make_preview(processed_file, dest_path, max_width: 500, max_height: 500) do
      media =
        MediaItem.changeset(%MediaItem{}, %{
          user_id: owner,
          url: res.url,
          type: processed_file.type,
          metadata: %{
            preview_url: preview.url
          }
        })
        |> Repo.insert!()

      {:ok, media}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def disable(id) do
    with {:ok, media} <- get(id) do
      media
      |> Repo.soft_delete()
    else
      error -> error
    end
  end

  @doc """
  Removes by `id` the media and it's files.
  """
  @spec remove(integer()) :: {:ok, Embers.Media.MediaItem.t()} | {:error, any()}
  def remove(id) do
    media = get(id)

    case media do
      nil ->
        :ok

      media ->
        with :ok <- remove_url(media),
             :ok <- remove_preview(media),
             {:ok, _media} <- Repo.delete(media) do
          :ok
        else
          error -> error
        end
    end
  end

  defp remove_url(%{type: "link"}), do: :ok

  defp remove_url(media) do
    {bucket, path} = media.url |> Uploads.parse_url()
    Uploads.delete(bucket, path)
  end

  defp remove_preview(media) do
    {bucket, path} = media.metadata["preview_url"] |> Uploads.parse_url()
    Uploads.delete(bucket, path)
  end

  defp process_file(%{content_type: "image/gif"} = file) do
    with :ok <- file.path |> SilentVideo.convert_mobile(file.path <> ".mp4") do
      {:ok,
       %{
         type: "gif",
         path: file.path <> ".mp4"
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp process_file(%{content_type: "image/" <> format} = file)
       when format in @supported_formats do
    processed_file =
      file.path
      |> Mogrify.open()
      |> Mogrify.custom("strip")
      |> Mogrify.resize_to_limit("1500x1500")
      |> Mogrify.custom("background", "#1a1b1d")
      |> Mogrify.format(format)
      |> Mogrify.save()

    {:ok,
     %{
       type: "image",
       path: processed_file.path
     }}
  end

  defp process_file(%{content_type: "video/" <> format} = file)
       when format in @supported_formats do
    with :ok <- file.path |> SilentVideo.convert_mobile(file.path <> ".mp4") do
      {:ok,
       %{
         type: "video",
         path: file.path <> ".mp4"
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp process_file(_file) do
    {:error, :file_not_supported}
  end

  defp make_preview(file, dest_path, opts) do
    preview_path = file.path <> ".preview.jpg"
    Thumbnex.create_thumbnail(file.path, preview_path, opts)

    Uploads.upload(preview_path, get_bucket(), dest_path <> "_preview.jpg")
  end

  defp get_file_ext(file) do
    Path.extname(file.path) |> String.slice(1..-1)
  end

  defp get_bucket() do
    Keyword.get(Application.get_env(:embers, Embers.Media), :bucket, "local")
  end
end
