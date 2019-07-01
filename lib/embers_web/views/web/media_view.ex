defmodule EmbersWeb.MediaView do
  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render("media.json", %{media: media}) do
    timestamp =
      unless is_nil(media.inserted_at) do
        media.inserted_at
        |> NaiveDateTime.to_erl()
        |> :calendar.datetime_to_gregorian_seconds()
        |> Kernel.-(62_167_219_200)
      end

    %{
      id: IdHasher.encode(media.id),
      url: media.url,
      type: media.type,
      temp: media.temporary,
      metadata: media.metadata,
      timestamp: timestamp
    }
  end
end