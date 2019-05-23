defmodule Embers.Links.YouTubeProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  @spec provides?(binary()) :: boolean()
  def provides?(url) do
    Regex.match?(
      ~r/https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com\S*[^\\w\-\s])([\w\-]{11})(?=[^\w\-]|$)(?![?=&+%\\w]*(?:['\"][^<>]*>|<\/a>))[?=&+%\w]*/i,
      url
    )
  end

  @spec get(binary()) :: Embers.Links.EmbedSchema.t()
  def get(url) do
    id = get_id(url)

    embed = %EmbedSchema{
      url: url,
      type: "video",
      html:
        "<iframe src='https://www.youtube.com/embed/#{id}' width='100%' height='400'></iframe>"
    }

    case OpenGraph.fetch(url) do
      {:error, _} ->
        %{embed | title: url}

      {:ok, og} ->
        %{
          embed
          | title: og.title,
            description: og.description,
            thumbnail_url: og.image
        }
    end
  end

  defp get_id(url) do
    [_, id] =
      Regex.run(
        ~r/https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com\S*[^\\w\-\s])([\w\-]{11})(?=[^\w\-]|$)(?![?=&+%\\w]*(?:['\"][^<>]*>|<\/a>))[?=&+%\w]*/i,
        url
      )

    id
  end
end
