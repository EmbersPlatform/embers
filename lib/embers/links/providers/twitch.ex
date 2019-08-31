defmodule Embers.Links.TwitchProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  def provides?(url) do
    Regex.match?(~r/(?:twitch\.tv\/)(?:\w+\/clip)\/(\w+)/, url)
  end

  def get(url) do
    [_, slug] = Regex.run(~r/(?:twitch\.tv\/)(?:\w+\/clip)\/(\w+)/, url)

    {title, desc} =
      case OpenGraph.fetch(url) do
        {:ok, og} -> {og.title, og.description}
        {:error, _} -> {url, nil}
      end

    %EmbedSchema{
      url: url,
      type: "video",
      title: title,
      description: desc,
      html:
        "<iframe src='https://clips.twitch.tv/embed?clip=#{slug}&autoplay=false' 'frameborder='0' scrolling='no' allowfullscreen='true' height='360' width='640'></iframe>"
    }
  end
end
