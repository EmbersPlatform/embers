defmodule Embers.Links.SteamProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  def provides?(url) do
    Regex.match?(~r/(?:https?:\/\/)?store\.steampowered\.com\/(?:app)\/([0-9]+)\/?(?:.*?)/i, url)
  end

  def get(url) do
    [_, id] =
      Regex.run(~r/(?:https?:\/\/)?store\.steampowered\.com\/(?:app)\/([0-9]+)\/?(?:.*?)/i, url)

    with {:ok, response} <- fetch_details(id),
         {:ok, body} <- Jason.decode(response.body),
         %{"success" => true, "data" => app} <- body[id] do
      %EmbedSchema{
        url: url,
        type: "link",
        title: app["name"],
        description: app["short_description"],
        thumbnail_url: app["header_image"],
        price: app["price_overview"]["final_formatted"] || "GRATIS"
      }
    else
      _ ->
        %EmbedSchema{
          url: url,
          type: "link"
        }
    end
  end

  defp fetch_details(id) do
    HTTPoison.get("https://store.steampowered.com/api/appdetails?appids=#{id}&cc=us")
  end
end
