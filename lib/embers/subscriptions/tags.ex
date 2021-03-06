defmodule Embers.Subscriptions.Tags do
  @moduledoc """
  See `Embers.Subscriptions` and `Embers.Blocks` for more details.
  """
  alias Embers.Blocks.TagBlock
  alias Embers.Subscriptions.TagSubscription
  alias Embers.Paginator
  alias Embers.Repo

  import Ecto.Query

  @spec get_sub_for(String.t(), String.t()) :: nil | TagSubscription.t()
  def get_sub_for(tag_id, user_id) do
    Repo.get_by(TagSubscription, user_id: user_id, source_id: tag_id)
  end

  def create_subscription(attrs \\ %{}) do
    subscription = TagSubscription.create_changeset(%TagSubscription{}, attrs)
    Repo.insert(subscription)
  end

  def create_or_update_subscription(attrs) do
    case get_sub_for(attrs.source_id, attrs.user_id) do
      nil ->
        subscription = TagSubscription.create_changeset(%TagSubscription{}, attrs)
        Repo.insert(subscription)

      sub ->
        subscription = TagSubscription.create_changeset(sub, attrs)
        Repo.update(subscription)
    end
  end

  def delete_subscription(user_id, source_id) do
    sub = get_sub_for(source_id, user_id)

    unless is_nil(sub) do
      Repo.delete(sub)
    end
  end

  def list_subscribed_tags_ids(user_id, opts \\ []) do
    Repo.all(
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        select: sub.source_id
      )
      |> maybe_with_level(opts)
    )
  end

  def list_users_following_tag_ids(tag_id, opts \\ []) do
    Repo.all(
      from(
        sub in TagSubscription,
        where: sub.source_id == ^tag_id,
        select: sub.user_id
      )
      |> maybe_with_level(opts)
    )
  end

  def list_subscribed_tags_ids_paginated(user_id, opts \\ []) do
    query =
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        select: sub.source_id
      )
      |> maybe_with_level(opts)

    Paginator.paginate(query, opts)
  end

  def list_users_following_tag_ids_paginated(tag_id, opts \\ []) do
    query =
      from(
        sub in TagSubscription,
        where: sub.source_id == ^tag_id,
        select: sub.user_id
      )
      |> maybe_with_level(opts)

    Paginator.paginate(query, opts)
  end

  def list_subscribed_tags_paginated(user_id, opts \\ []) do
    query =
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        left_join: tag in assoc(sub, :source),
        select: %{tag: tag, level: sub.level}
      )
      |> maybe_with_level(opts)

    Paginator.paginate(query, opts)
  end

  def list_subscribed_tags(user_id, opts \\ []) do
    Repo.all(
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        left_join: tag in assoc(sub, :source),
        select: %{tag: tag, level: sub.level}
      )
      |> maybe_with_level(opts)
    )
  end

  def list_users_following_tag_paginated(tag_id, opts \\ []) do
    query =
      from(
        sub in TagSubscription,
        where: sub.source_id == ^tag_id,
        left_join: user in assoc(sub, :user),
        select: user
      )
      |> maybe_with_level(opts)

    Paginator.paginate(query, opts)
  end

  def list_blocked_tags_paginated(user_id, opts \\ []) do
    from(
      b in TagBlock,
      where: b.user_id == ^user_id,
      left_join: tag in assoc(b, :tag),
      select: tag
    )
    |> Paginator.paginate(opts)
  end

  def list_blocked_tags_ids_paginated(user_id, opts \\ []) do
    from(
      b in TagBlock,
      where: b.user_id == ^user_id,
      select: b.tag_id
    )
    |> Paginator.paginate(opts)
  end

  def create_block(user_id, tag_name) when is_binary(tag_name) do
    tag = Embers.Tags.create_tag(tag_name)
    create_block(user_id, tag.id)
  end

  def create_block(user_id, tag_id) when is_integer(tag_id) do
    block = TagBlock.create_changeset(%TagBlock{}, %{user_id: user_id, tag_id: tag_id})
    Repo.insert(block)
  end

  def update_block(block_id, attrs \\ %{}) do
    block = Repo.get_by(TagBlock, %{id: block_id})

    unless is_nil(block) do
      block
      |> TagBlock.create_changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_block(user_id, tag_id) do
    block = Repo.get_by(TagBlock, %{user_id: user_id, tag_id: tag_id})

    unless is_nil(block) do
      Repo.delete(block)
    end
  end

  defp maybe_with_level(query, opts) do
    level = Keyword.get(opts, :level)

    if not is_nil(level) do
      from(s in query, where: s.level == ^level)
    end || query
  end

  @spec get_sub_level(String.t(), nil | String.t()) :: integer()
  def get_sub_level(_, nil), do: nil

  def get_sub_level(user_id, tag_id) do
    case get_sub_for(tag_id, user_id) do
      nil -> nil
      sub -> sub.level
    end
  end

  @spec list_pinned(binary(), keyword()) :: [TagSubscription.t()]
  def list_pinned(user_id, _opts \\ []) do
    Repo.all(
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        left_join: tag in assoc(sub, :source),
        select: %{tag: tag, level: sub.level}
      )
    )
  end
end
