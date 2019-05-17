defmodule Embers.Feed.Subscriptions.Tags do
  @moduledoc """
  Este módulo es la interfaz para las suscripciones y bloqueos a tags.

  Para una explicación más detallada sobre qué son las suscripciones y
  bloqueos, ver la documentación de los módulos `Embers.Feed.Subscriptions` y
  `Embers.Feed.Subscriptions.Blocks`.
  """
  alias Embers.Feed.Subscriptions.{TagBlock, TagSubscription}
  alias Embers.Paginator
  alias Embers.Repo

  import Ecto.Query

  def create_subscription(attrs \\ %{}) do
    subscription = TagSubscription.create_changeset(%TagSubscription{}, attrs)
    Repo.insert(subscription)
  end

  def delete_subscription(user_id, source_id) do
    sub = Repo.get_by(TagSubscription, %{user_id: user_id, source_id: source_id})

    unless is_nil(sub) do
      Repo.delete(sub)
    end
  end

  def list_subscribed_tags_ids(user_id) do
    Repo.all(
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        select: sub.source_id
      )
    )
  end

  def list_users_following_tag_ids(tag_id) do
    Repo.all(
      from(
        sub in TagSubscription,
        where: sub.source_id == ^tag_id,
        select: sub.user_id
      )
    )
  end

  def list_subscribed_tags_ids_paginated(user_id, opts) do
    query =
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        select: sub.source_id
      )

    Paginator.paginate(query, opts)
  end

  def list_users_following_tag_ids_paginated(tag_id, opts) do
    query =
      from(
        sub in TagSubscription,
        where: sub.source_id == ^tag_id,
        select: sub.user_id
      )

    Paginator.paginate(query, opts)
  end

  def list_subscribed_tags_paginated(user_id, opts) do
    query =
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        left_join: tag in assoc(sub, :source),
        select: tag
      )

    Paginator.paginate(query, opts)
  end

  def list_subscribed_tags(user_id) do
    Repo.all(
      from(
        sub in TagSubscription,
        where: sub.user_id == ^user_id,
        left_join: tag in assoc(sub, :source),
        select: tag
      )
    )
  end

  def list_users_following_tag_paginated(tag_id, opts) do
    query =
      from(
        sub in TagSubscription,
        where: sub.source_id == ^tag_id,
        left_join: user in assoc(sub, :user),
        select: user
      )

    Paginator.paginate(query, opts)
  end

  def create_block(attrs \\ %{}) do
    block = TagBlock.create_changeset(%TagBlock{}, attrs)
    Repo.insert(block)
  end

  def delete_block(user_id, tag_id) do
    block = Repo.get_by(TagBlock, %{user_id: user_id, tag_id: tag_id})

    unless is_nil(block) do
      Repo.delete(block)
    end
  end
end
