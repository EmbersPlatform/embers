defmodule Embers.Media do
  alias Embers.Media.Image
  alias Embers.Media.MediaItem
  alias Embers.Repo

  import Ecto.Query

  def upload(file, owner) do
    name = Ecto.UUID.generate()
    _ext = Path.extname(file.filename)

    with {:ok, filename} <- Image.store({file, name}) do
      media =
        MediaItem.changeset(%MediaItem{}, %{
          user_id: owner,
          url: name <> ".png",
          filename: name,
          original_filename: filename
        })
        |> Repo.insert!()

      {:ok, media}
    else
      err -> err
    end
  end

  def remove(id) do
    media = MediaItem |> where([m], m.id == ^id) |> Repo.one!()

    Image.delete({media.original_filename, media.filename})

    Repo.delete(media)
  end
end
