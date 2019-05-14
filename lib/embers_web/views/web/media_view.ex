defmodule EmbersWeb.MediaView do
  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("media.json", %{media: media}) do
    %{
      id: IdHasher.encode(media.id),
      url: media.url,
      type: media.type,
      temp: media.temporary,
      metadata: media.metadata
    }
  end
end
