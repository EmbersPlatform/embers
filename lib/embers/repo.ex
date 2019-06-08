defmodule Embers.Repo do
  use Ecto.Repo, otp_app: :embers, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 20

  import Ecto.Query

  def soft_delete(query) do
    query
    |> Ecto.Changeset.change(
      deleted_at: Timex.now() |> Timex.to_naive_datetime() |> NaiveDateTime.truncate(:second)
    )
    |> __MODULE__.update()
  end

  def restore_entry(query) do
    query
    |> Ecto.Changeset.change(deleted_at: nil)
    |> __MODULE__.update()
  end

  def with_undeleted(query) do
    query
    |> where([t], is_nil(t.deleted_at))
  end
end
