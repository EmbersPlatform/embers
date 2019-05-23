defmodule EmbersWeb.LinkView do
  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("link.json", %{link: link}) do
    embed =
      link.embed
      |> clean_embed()

    %{
      "id" => IdHasher.encode(link.id),
      "url" => link.url,
      "embed" => embed
    }
  end

  defp clean_embed(embed) do
    embed
    |> Map.from_struct()
    |> Map.drop([:__meta__, :id])
  end
end
