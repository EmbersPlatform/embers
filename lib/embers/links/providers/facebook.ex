defmodule Embers.Links.FacebookProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  def provides?(url) do
    Regex.match?(~r/facebook.com/, url)
  end

  def get(url) do
    og = OpenGraph.fetch(url)

    case og do
      {:error, _} ->
        %EmbedSchema{url: url, type: "link"}

      {:ok, og} ->
        og_to_schema(og, url)
    end
  end

  def og_to_schema(og, url) do
    schema = %EmbedSchema{
      url: og.url || url,
      type: og.type || "link",
      title: og.title,
      description: og.description,
      thumbnail_url: og.image
    }

    case og.type do
      "video.other" ->
        %{
          schema
          | type: "video",
            html: """
              <video controls><source src="#{og.video}" type="video/mp4"></video>"
            """
        }

      _ ->
        schema
    end
  end
end
