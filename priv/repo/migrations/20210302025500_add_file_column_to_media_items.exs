defmodule Embers.Repo.Migrations.AddFileColumnToMediaItems do
  use Ecto.Migration

  import Ecto.Query, only: [from: 2]

  @batch_size 1000

  def up do
    alter table(:media_items) do
      add(:file, :map)
    end

    flush()

    convert_urls_to_maps(repo())
  end

  def down do
    alter table(:media_items) do
      remove(:file)
    end
  end

  defp convert_urls_to_maps(repo) do
    from(media in "media_items", select:
      %{id: media.id,
        url: media.url,
        file: media.file,
        type: media.type,
        metadata: media.metadata,
        user_id: media.user_id,
        inserted_at: media.inserted_at,
        updated_at: media.updated_at
      }
    )
    |> repo.stream(max_rows: @batch_size)
    |> Stream.map(&fill_media_file_map/1)
    |> Stream.chunk_every(@batch_size)
    |> Stream.map(&save_medias(&1, repo))
    |> Stream.run()
  end

  defp fill_media_file_map(media) do
    %{path: path} = URI.parse(media.url)
    [_, bucket | path] = Path.split(path)
    filename = Path.basename(path)

    file = %{
      filename: filename,
      path: Path.join(path),
      bucket: bucket
    }

    %{media | file: file}
  end

  defp save_medias(medias, repo) do
    repo.insert_all(
      "media_items", medias,
      conflict_target: [:id],
      on_conflict: {:replace, [:file]}
    )
  end
end
