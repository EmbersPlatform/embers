defmodule Embers.Links.SoundcloudProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  def provides?(url) do
    Regex.match?(~r/^https?:\/\/(soundcloud\.com|snd\.sc)\/(.*)$/i, url)
  end

  def get(url) do
    encoded_url = URI.encode(url)

    embed = %EmbedSchema{
      url: url,
      html:
        "<iframe width='100%' height='450' scrolling='no' frameborder='no' src='https://w.soundcloud.com/player/?visual=true&url=#{
          encoded_url
        }&show_artwork=true'></iframe>",
      type: "rich"
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
end
