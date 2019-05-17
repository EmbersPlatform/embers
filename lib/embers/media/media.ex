defmodule Embers.Media do
  @moduledoc """
  Los medios, o media, son archivos subidos por los usuarios, como las
  imagenes o los videos.

  Los archivos son guardados en el almacenamiento definido en la configuracion,
  y en la base de datos se guarda una entrada `Embers.Media.MediaItem` que
  contiene el tipo y la url del archivo.

  Para ver mas sobre como se guardan los archivos, ver el modulo
  `Embers.Uploads`

  ## Medios temporales
  Por defecto, al crear un medio, es marcado como temporal. El motivo es que
  al crear un post(que es para lo cual se implementaron aunque se le pueden dar
  mas usos), se devuelve al cliente un medio que podria no ser publicado con
  ningun post.

  Para evitar la existencia de medios sin usar, se marcan como temporales al
  ser creados, y requieren que se los "confirme" quitando esta marca.

  Marcarlos como temporales permite correr alguna tarea que levante todos los
  medios temporales que superen el tiempo de vida maximo permitido y los
  elimine.

  ## Manipulacion de imagenes
  Los medios, antes de ser guardados, son modificados para asegurar que
  cumplen con dimensiones maximas y formatos validos para Embers.

  La manipulacion de imagenes se realiza mediante la libreria `Mogrify`,
  que es una interfaz para utilizar la herramienta de ImageMagick.
  """
  alias Embers.Media.MediaItem
  alias Embers.Repo
  alias Embers.Thumbnex
  alias Embers.Uploads

  import Ecto.Query

  require Logger

  @supported_formats ~w(jpg jpeg png gif webm mp4)

  @doc """
  Devuelve un medioo por su id
      iex> get(1)
      %MediaItem{}
  """
  def get(id) do
    MediaItem |> where([m], m.id == ^id) |> Repo.one()
  end

  @doc """
  Sube un medio al almacenamiento y crea una entrada en la base de datos.
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
             get_bucket(),
             dest_path <> ".#{ext}"
           ),
         {:ok, preview} <-
           make_preview(processed_file, dest_path, max_width: 500, max_height: 500) do
      media =
        Repo.insert!(
          MediaItem.changeset(%MediaItem{}, %{
            user_id: owner,
            url: res.url,
            type: processed_file.type,
            metadata: %{
              preview_url: preview.url
            }
          })
        )

      {:ok, media}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Realiza un soft-delete sobre el medio
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

  # Esta funcion se encarga de manipular el archivo para darle el formato
  # esperado.
  # En el caso de las imagenes, limita el tamaño a 1500x1500px.
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

  # En este caso, convierte el video a video mudo, esto es ideal para los gifs,
  # pero si es otro tipo de video habria que procesarlo de otra manera.
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

  # Esta funcion usa la libreria Thumbnex para extraer la vista previa de un
  # archivo. En el caso de los videos, seria el primer cuadro.
  defp make_preview(file, dest_path, opts) do
    preview_path = file.path <> ".preview.jpg"
    Thumbnex.create_thumbnail(file.path, preview_path, opts)

    Uploads.upload(preview_path, get_bucket(), dest_path <> "_preview.jpg")
  end

  defp get_file_ext(file) do
    file.path
    |> Path.extname()
    |> String.slice(1..-1)
  end

  defp get_bucket do
    Keyword.get(Application.get_env(:embers, Embers.Media), :bucket, "local")
  end
end
