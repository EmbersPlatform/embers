defmodule EmbersWeb.MediaView do
  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("media.json", %{media: media}) do
    %{
      id: IdHasher.encode(media.id),
      url: media.url,
      temp: media.temporary
    }
  end
end
