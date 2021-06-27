defmodule EmbersWeb.LinkView do
  @moduledoc false

  use EmbersWeb, :view

  def render("link.json", %{link: link}) do
    embed =
      link.embed
      |> clean_embed()

    %{
      "id" => link.id,
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
