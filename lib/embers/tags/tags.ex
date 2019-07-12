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

  alias Embers.Posts.Post
  alias Embers.Subscriptions.TagSubscription
  alias Embers.Repo
  alias Embers.Paginator
  alias Embers.Tags.{Tag, TagPost}

  import Ecto.Query

  def get(id) do
    Repo.get(Tag, id)
  end

  def get_by(clauses, opts \\ []) do
    Repo.get_by(Tag, clauses, opts)
  end

  def get_by_name(name) when is_binary(name) do
    name = String.downcase(name)

    Repo.one(from(tag in Tag, where: fragment("LOWER(?) = ?", tag.name, ^name), limit: 1))
  end

  def create_tag(%{"name" => name}) do
    case get_by_name(name) do
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
          changeset.changes
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
        where: not ilike(tag.name, "nsfw"),
        group_by: tag.id,
        select: %{
          tag: tag,
          count: fragment("count(?) as tag_count", tag_post.id)
        },
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
        where: not ilike(tag.name, "nsfw"),
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

  def list_post_tag_names(post_id) do
    query =
      from(
        tp in TagPost,
        where: tp.post_id == ^post_id,
        left_join: tag in assoc(tp, :tag),
        select: tag.name
      )

    Repo.all(query)
  end

  defp insert_tag(name) do
    tag = Tag.create_changeset(%Tag{}, %{"name" => name})
    Repo.insert!(tag)
  end

  def add_tag(post, tag_name) when is_binary(tag_name) do
    tag = create_tag(%{"name" => tag_name})
    add_tag(post, tag.id)
  end

  def add_tag(%Post{id: pid}, tid) do
    add_tag(pid, tid)
  end

  def add_tag(pid, tid) do
    %TagPost{}
    |> TagPost.create_changeset(%{post_id: pid, tag_id: tid})
    |> Repo.insert()
  end

  def remove_tag(post, tag_name) when is_binary(tag_name) do
    case Repo.get_by(Tag, %{name: tag_name}) do
      nil -> nil
      tag -> remove_tag(post, tag.id)
    end
  end

  def remove_tag(%Post{id: pid}, tid) do
    remove_tag(pid, tid)
  end

  def remove_tag(pid, tid) do
    case Repo.get_by(TagPost, %{post_id: pid, tag_id: tid}) do
      nil -> nil
      tag_post -> Repo.delete(tag_post)
    end
  end

  def tags_loaded(%Post{tags: tags}) do
    tags |> Enum.map(& &1.name)
  end

  def update_tags(post, new_tags) when is_list(new_tags) do
    old_tags = tags_loaded(post)
    Enum.each(new_tags -- old_tags, &add_tag(post, &1))
    Enum.each(old_tags -- new_tags, &remove_tag(post, &1))
  end

  def update_tag(tag, attrs) do
    tag
    |> Tag.create_changeset(attrs)
    |> Repo.update()
  end

  def list_tag_posts(tag, params) do
    from(
      post in Post,
      where: is_nil(post.deleted_at),
      where: post.nesting_level == 0,
      where: is_nil(post.related_to_id),
      order_by: [desc: post.id],
      left_join: user in assoc(post, :user),
      left_join: meta in assoc(user, :meta),
      left_join: tags in assoc(post, :tags),
      where: ilike(tags.name, ^tag),
      preload: [
        [:media, :links, :reactions, :tags]
      ],
      preload: [
        user: {user, meta: meta}
      ]
    )
    |> Paginator.paginate(params)
    |> fill_nsfw()
  end

  defp fill_nsfw(page) do
    %{
      page
      | entries: Enum.map(page.entries, fn post -> Post.fill_nsfw(post) end)
    }
  end
end
