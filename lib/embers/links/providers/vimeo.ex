defmodule Embers.Links.VimeoProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  @spec provides?(binary()) :: boolean()
  def provides?(url) do
    Regex.match?(
      ~r/(?:www\.|player\.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|album\/(?:\d+)\/video\/|video\/|)(\d+)(?:[a-zA-Z0-9_\-]+)?/i,
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
        "<iframe src='https://player.vimeo.com/video/#{id}' width='100%' height='400' allowfullscreen></iframe>"
    }

    %{
      embed
      | title: "Vimeo",
        description: ""
    }
  end

  defp get_id(url) do
    [_, id] =
      Regex.run(
        ~r/(?:www\.|player\.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|album\/(?:\d+)\/video\/|video\/|)(\d+)(?:[a-zA-Z0-9_\-]+)?/i,
        url
      )

    id
  end
end
