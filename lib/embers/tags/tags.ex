defmodule Embers.Tags do
  @moduledoc """
  Los tags se utilizan para categorizar contenidos. Son también una
  Fuente para las suscripciones.

  La manera en que se relaciona un tag con un contenido es mediante una
  tabla pivote. Por ejemplo, para los posts seria la tabla "tag_post".

  ## Por hacer
  Resta hacer que los tags tengan una descripcion, editable solo por
  moderadores.
  """

  alias Embers.Feed.Subscriptions.TagSubscription
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

  def get_hot_tags(opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    since_date =
      Timex.now()
      |> Timex.shift(days: -1)
      |> Timex.beginning_of_day()

    query =
      from(
        tag_post in TagPost,
        where: tag_post.inserted_at >= ^since_date,
        left_join: tag in assoc(tag_post, :tag),
        group_by: tag.id,
        select: %{tag: tag, count: fragment("count(?) as tag_count", tag_post.id)},
        order_by: [desc: fragment("tag_count")],
        limit: ^limit
      )

    Repo.all(query)
  end

  def get_popular_tags(opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    query =
      from(
        tag_user in TagSubscription,
        left_join: tag in assoc(tag_user, :source),
        left_join: user in assoc(tag_user, :user),
        group_by: tag.id,
        select: %{tag: tag, count: fragment("count(?) as user_count", user.id)},
        order_by: [desc: fragment("user_count")],
        limit: ^limit
      )

    Repo.all(query)
  end

  def list_post_tags_ids(post_id) do
    query =
      from(
        tp in TagPost,
        where: tp.post_id == ^post_id,
        select: tp.tag_id
      )

    Repo.all(query)
  end

  defp insert_tag(name) do
    tag = Tag.create_changeset(%Tag{}, %{"name" => name})
    Repo.insert!(tag)
  end
end
