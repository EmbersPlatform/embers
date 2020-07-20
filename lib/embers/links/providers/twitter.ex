defmodule Embers.Links.TwitterProvider do
  @moduledoc false

  @behaviour Embers.Links.Provider

  alias Embers.Links.EmbedSchema

  def provides?(url) do
    Regex.match?(~r/^https?:\/\/(?:twitter\.com)\/(?:.*)\/status\/(\d+)$/i, url)
  end

  def get(url) do
    [_, id] = Regex.run(~r/^https?:\/\/(?:twitter\.com)\/(?:.*)\/status\/(\d+)$/i, url)

    %EmbedSchema{
      url: url,
      type: "link",
      html: "<twitter-embed data-id=\"#{id}\"></twitter-embed>"
    }
  end
end
