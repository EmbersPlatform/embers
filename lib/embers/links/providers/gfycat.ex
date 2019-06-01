defmodule Embers.Links.GfycatProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  def provides?(url) do
    Regex.match?(~r/(?:.*)gfycat.com\/([a-zA-Z]*)/i, url)
  end

  def get(url) do
    [_, id] = Regex.run(~r/(?:.*)gfycat.com\/([a-zA-Z]*)/i, url)

    %EmbedSchema{
      url: url,
      type: "video",
      title: url,
      html:
        "<iframe width='100%' height='400' src='https://gfycat.com/ifr/#{id}?autoplay=0'></iframe>"
    }
  end
end
