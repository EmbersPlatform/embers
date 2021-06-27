defmodule Embers.OpenGraph.SteamProvider do
  @behaviour Embers.OpenGraph.Provider

  def provides?(url) do
    Regex.match?(~r/http?s:\/\/store\.steampowered\.com\/app\//i, url)
  end

  def get(url) do
    [appid] =
      Regex.run(~r/http?s:\/\/store\.steampowered\.com\/app\/([0-9]*)/i, url,
        capture: :all_but_first
      )

    {:ok, %{body: response}} =
      HTTPoison.get("https://store.steampowered.com/api/appdetails?appids=#{appid}&cc=us", [],
        follow_redirect: true,
        ssl: [{:versions, [:"tlsv1.2"]}]
      )

    {:ok, response} = Jason.decode(response)

    %{
      "data" => data
    } = response[appid]

    %{
      title: data["name"],
      provider_name: "Steam",
      provider_url: "https://store.steampowered.com/",
      url: "https://store.steampowered.com/app/#{appid}",
      author_name: Enum.join(data["developers"], ", "),
      author_url: data["website"],
      thumbnail_url: data["header_image"],
      price: data["price_overview"]["final_formatted"],
      description: data["short_description"]
    }
  end
end
