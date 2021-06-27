defmodule Embers.Media do
  @moduledoc """
  Media are the user uploaded images and videos.

  The actual files are stored via `Embers.Uploads`, the `MediaItem` holds
  metadata about the file, such as it's url, path, or dimensions.

  ## Temporary Medias
  When created, a the media is flagged as "temporary". A media is usually
  uploaded by the client while editing a post. If the post is never submitted,
  or the media is removed from it, it would be "orphaned" from it's associated
  entity. When the post is submitted, the `:temporary` flag is set to false.
  This design might change in the future, but in it's current form should allow
  the implementation of more entities that can have medias a bit more
  straightforward.

  There should be a process that looks for stale temporary medias and prune them.

  ## Image processing
  `Media`s are processed before being saved so they fit the max dimensions and
  format allowed by Embers.

  `Mogrify` and `FFmpex` libraries are used.
  """
  use FFmpex.Options

  alias Embers.Media.MediaItem
  alias Embers.Repo
  alias Thumbnex
  alias Embers.Uploads

  import Ecto.Query

  require Logger

  @supported_formats ~w(jpg jpeg png gif webm mp4)

  @doc """
  Gets a media by it's id
      iex> get(1)
      %MediaItem{}
  """
  def get(id) do
    MediaItem |> where([m], m.id == ^id) |> Repo.one()
  end

  @doc """
  Uploads a media and creates an entry in the database
      iex> upload(file, 1)
      %MediaItem{user_id: 1, ...}
  """
  def upload(file, owner) do
    name = Ecto.UUID.generate()

    dest_path = "media/#{name}"

    with {:ok, processed_file} <- process_file(file),
         ext <- get_file_ext(processed_file),
         {:ok, res} <-
           Uploads.upload(
             processed_file.path,
             dest_path <> ".#{ext}",
             content_type: processed_file.content_type
           ),
         {:ok, preview} <-
           make_preview(processed_file, dest_path, max_width: 800, max_height: 800) do
      media_data = %{
        user_id: owner,
        url: res.url,
        type: processed_file.type,
        metadata: %{
          preview_url: preview.url
        }
      }

      media_data =
        if media_data.type == "image" do
          case Fastimage.size(processed_file.path) do
            %{height: height, width: width} ->
              metadata =
                media_data.metadata
                |> Map.put(:height, height)
                |> Map.put(:width, width)

              %{media_data | metadata: metadata}
          end
        end || media_data

      media = Repo.insert!(MediaItem.changeset(%MediaItem{}, media_data))

      {:ok, media}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def format_url(url) when is_binary(url) do
    uri = URI.parse(url)

    if is_nil(uri.host) do
      "/#{uri.path}"
    else
      URI.to_string(uri)
    end
  end

  @doc """
  Soft deletes a media
  """
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
        end
    end
  end

  @temporary_ttl 1
  def expired_query do
    from_date =
      Timex.now()
      |> Timex.shift(hours: -@temporary_ttl)

    from(media in MediaItem,
      where: media.temporary,
      where: media.inserted_at <= ^from_date
    )
  end

  def get_expired do
    expired_query()
    |> Repo.all()
  end

  def prune_expired do
    stream =
      expired_query()
      |> Repo.stream()

    Repo.transaction(fn ->
      stream
      |> Stream.each(fn media ->
        remove(media.id)
      end)
      |> Stream.run()
    end)

    :ok
  end

  @doc """
  Returns a list with all the orphan medias ids
  """
  @spec list_orphans_ids() :: [String.t()]
  def list_orphans_ids do
    from(
      media in MediaItem,
      left_join: mp in "posts_medias",
      on: mp.media_item_id == media.id,
      where: is_nil(mp.post_id),
      select: media.id
    )
    |> Repo.all()
  end

  @doc """
  TODO
  """
  @spec prune_orphans() :: {:ok, integer()}
  def prune_orphans do
    from(
      media in MediaItem,
      left_join: mp in "posts_medias",
      on: mp.media_item_id == media.id,
      where: is_nil(mp.post_id),
      select: count(media.id)
    )
    |> Repo.all()
  end

  defp remove_url(%{type: "link"}), do: :ok

  defp remove_url(media) do
    path = media.url |> Uploads.get_path()
    Uploads.delete(path)
  end

  defp remove_preview(media) do
    path = media.metadata["preview_url"] |> Uploads.get_path()
    Uploads.delete(path)
  end

  defp process_file(%{content_type: "image/gif"} = file) do
    with :ok <- file.path |> File.rename(file.path <> ".gif") do
      {:ok,
       %{
         type: "gif",
         path: file.path <> ".gif",
         content_type: "image/gif"
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
      |> Mogrify.format(format)
      |> Mogrify.save()

    {:ok,
     %{
       type: "image",
       path: processed_file.path,
       content_type: "image/#{format}"
     }}
  end

  defp process_file(%{content_type: "video/" <> format} = file)
       when format in @supported_formats do
    with :ok <- file.path |> process_video(file.path <> ".mp4") do
      {:ok,
       %{
         type: "video",
         path: file.path <> ".mp4",
         content_type: "video/mp4"
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

    Uploads.upload(preview_path, dest_path <> "_preview.jpg", content_type: "image/jpg")
  end

  defp get_file_ext(file) do
    file.path
    |> Path.extname()
    |> String.slice(1..-1)
  end

  defp process_video(video_path, output_path) do
    FFmpex.new_command()
    |> FFmpex.add_global_option(option_y())
    |> FFmpex.add_input_file(video_path)
    |> FFmpex.add_output_file(output_path)
    |> FFmpex.add_stream_specifier(stream_type: :video)
    |> FFmpex.add_stream_option(option_codec("libx264"))
    |> FFmpex.add_stream_option(option_b(400_000))
    |> FFmpex.add_stream_option(option_maxrate(400_000))
    |> FFmpex.add_stream_option(option_bufsize(800_000))
    |> FFmpex.add_file_option(option_profile("main"))
    |> FFmpex.add_file_option(option_r(30))
    |> FFmpex.add_file_option(option_movflags("faststart"))
    |> FFmpex.execute()
  end
end
