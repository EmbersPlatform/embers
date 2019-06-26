defmodule Embers.Links do
  @moduledoc """
  Los `Link`s son enlaces publicados por los usuarios, generalmente en un
  `Post`.

  Los `Links` contienen la URL y metadatos sobre el enlace necesarios para su
  representacion gráfica, tales como el título o una imagen de vista previa.

  La principal diferencia entre un `Media` y un `Link` es que los Links no
  apuntan  ningún archivo alojado por Embers, sino que almacenan metadatos.

  El motivo por el cual existen como entidades separadas es que si bien los
  `Media` almacenan metadatos, al ser representaciones de archivos *físicos*
  se debe tener especial cuidado a la hora de almacenar/eliminar `Media`s.
  """

  alias Embers.Feed.Post
  alias Embers.Links.{EmbedSchema, Link, LinkPost}
  alias Embers.Repo

  @providers [
    Embers.Links.GfycatProvider,
    Embers.Links.SoundcloudProvider,
    Embers.Links.SteamProvider,
    Embers.Links.TwitterProvider,
    Embers.Links.YouTubeProvider
  ]

  def get_by(%{id: id}) do
    Repo.get(Link, id)
  end

  def get_by(%{url: url}) do
    Repo.get_by!(Link, url: url)
  end

  def save(attrs) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  def attach_to(%Link{id: link}, %Post{id: post}) do
    attach_to(link, post)
  end

  def attach_to(%Link{id: link}, post) when is_integer(post) do
    attach_to(link, post)
  end

  def attach_to(link, post) when is_integer(link) and is_integer(post) do
    %LinkPost{}
    |> LinkPost.changeset(%{link_id: link, post_id: post})
    |> Repo.insert()
  end

  @spec fetch(binary()) :: {:error, :cant_process_url} | {:ok, Embers.Links.EmbedSchema.t()}
  def fetch(url) do
    content_type = get_content_type(url)

    if !is_nil(content_type) && Regex.match?(~r/image\/(\w+)/, content_type) do
      {:ok, handle_image(url)}
    else
      {:ok, handle_url(url)}
    end
  end

  defp handle_url(url) do
    case Enum.find(@providers, fn provider -> provider.provides?(url) end) do
      nil -> handle_og(url)
      provider -> provider.get(url)
    end
  end

  defp handle_og(url) do
    case OpenGraph.fetch(url) do
      {:error, _} ->
        nil

      {:ok, og} ->
        %EmbedSchema{
          url: og.url || url,
          type: og.type || "link",
          title: og.title,
          description: og.description,
          thumbnail_url: og.image
        }
    end
  end

  defp handle_image(url) do
    %EmbedSchema{
      url: url,
      type: "image",
      title: url,
      thumbnail_url: url
    }
  end

  defp get_content_type(url) do
    case HTTPoison.head(url) do
      {:ok, %{headers: headers}} ->
        with {_, content_type} <- List.keyfind(headers, "Content-Type", 0) do
          content_type
        else
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
