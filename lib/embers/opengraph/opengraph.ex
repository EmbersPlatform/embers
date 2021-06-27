defmodule OpenGraph do
  @moduledoc """
  Fetch and parse websites to extract Open Graph meta tags.
  The example above shows how to fetch the GitHub Open Graph rich objects.
  ```
  OpenGraph.fetch("https://github.com")
  %OpenGraph{description: "GitHub is where people build software. More than 15 million...",
  image: "https://assets-cdn.github.com/images/modules/open_graph/github-octocat.png",
  site_name: "GitHub", title: "Build software better, together", type: nil,
  url: "https://github.com"}
  ```
  """

  @metatag_regex ~r/<\s*meta\s(?=[^>]*?\bproperty\s*=\s*(?|"\s*([^"]*?)\s*"|'\s*([^']*?)\s*'|([^"'>]*?)(?=\s*\/?\s*>|\s\w+\s*=)))[^>]*?\bcontent\s*=\s*(?|"\s*([^"]*?)\s*"|'\s*([^']*?)\s*'|([^"'>]*?)(?=\s*\/?\s*>|\s\w+\s*=))[^>]*>/

  defstruct [:title, :type, :image, :video, :url, :description, :site_name]

  @doc """
  Fetches the raw HTML for the given website URL.
  Args:
    * `url` - target URL as a binary string or char list
  This functions returns `{:ok, %OpenGraph{...}}` if the request is successful,
  `{:error, reason}` otherwise.
  """
  def fetch(url) do
    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, OpenGraph.parse(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found :("}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Parses the given HTML to extract the Open Graph objects.
  Args:
    * `html` - raw HTML as a binary string or char list
  This functions returns an OpenGraph struct.
  """
  def parse(html) do
    map =
      @metatag_regex
      |> Regex.scan(html, capture: :all_but_first)
      |> Enum.filter(&filter_og_metatags(&1))
      |> Enum.map(&drop_og_prefix(&1))
      |> Enum.into(%{}, fn [k, v] -> {k, v} end)
      |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)

    struct(OpenGraph, map)
  end

  defp filter_og_metatags(["og:" <> _property, _content]), do: true
  defp filter_og_metatags(_), do: false

  defp drop_og_prefix(["og:" <> property, content]) do
    [property, content]
  end
end
