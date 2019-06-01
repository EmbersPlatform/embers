defmodule Embers.Links.TwitterProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  def provides?(url) do
    Regex.match?(~r/^https?:\/\/(?:twitter\.com)\/(?:.*)\/status\/(\d+)$/i, url)
  end

  def get(url) do
    [_, id] = Regex.run(~r/^https?:\/\/(?:twitter\.com)\/(?:.*)\/status\/(\d+)$/i, url)

    embed = %EmbedSchema{
      url: url
    }

    case OpenGraph.fetch(url) do
      {:error, _} ->
        %{embed | type: "link"}

      {:ok, og} ->
        embed = %{
          embed
          | type: og.type,
            title: og.title,
            description: og.description,
            thumbnail_url: og.image
        }

        embed =
          if og.type === "video" do
            %{
              embed
              | html:
                  "<iframe src='https://twitter.com/i/videos/#{id}' width='100%' height='400'></iframe>"
            }
          end || embed

        embed
    end
  end
end
