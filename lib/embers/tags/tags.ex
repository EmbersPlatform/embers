defmodule Embers.Tags do
  alias Embers.Repo
  alias Embers.Tags.{Tag, TagPost}

  import Ecto.Query

  def create_tag(%{"name" => name}) do
    case Repo.get_by(Tag, name: name) do
      nil -> insert_tag(name)
      tag -> tag
    end
  end

  @doc """
  Inserts the given tags, ignoring invalid ones.
  Returns the ids of the inserted tags
  """
  def bulk_create_tags(tags \\ []) do
    tags =
      tags
      |> Enum.map(fn tag ->
        attrs = %{name: tag}
        changeset = Tag.create_changeset(%Tag{}, attrs)

        if changeset.valid? do
          attrs
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq_by(& &1.name)

    {_count, records} =
      Repo.insert_all(
        Tag,
        tags,
        on_conflict: :replace_all_except_primary_key,
        conflict_target: [:name],
        returning: [:id]
      )

    records
    |> Enum.map(fn tag -> tag.id end)
  end

  def list_post_tags_ids(post_id) do
    from(
      tp in TagPost,
      where: tp.post_id == ^post_id,
      select: tp.tag_id
    )
    |> Repo.all()
  end

  defp insert_tag(name) do
    tag = Tag.create_changeset(%Tag{}, %{"name" => name})
    Repo.insert!(tag)
  end
end
