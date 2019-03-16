defmodule Embers.Feed.Subscriptions.Tags do
  alias Embers.Feed.Subscriptions.{TagSubscription, TagBlock}
  alias Embers.Repo
  alias Embers.Paginator

  import Ecto.Query

  def create_subscription(attrs \\ %{}) do
    subscription = TagSubscription.create_changeset(%TagSubscription{}, attrs)
    Repo.insert(subscription)
  end

  def delete_subscription(user_id, source_id) do
    sub = Repo.get_by(TagSubscription, %{user_id: user_id, source_id: source_id})

    if(not is_nil(sub)) do
      Repo.delete(sub)
    end
  end

  def list_subscribed_tags_ids(user_id) do
    from(
      sub in TagSubscription,
      where: sub.user_id == ^user_id,
      select: sub.source_id
    )
    |> Repo.all()
  end

  def list_users_following_tag_ids(tag_id) do
    from(
      sub in TagSubscription,
      where: sub.source_id == ^tag_id,
      select: sub.user_id
    )
    |> Repo.all()
  end

  def list_subscribed_tags_ids_paginated(user_id, opts) do
    from(
      sub in TagSubscription,
      where: sub.user_id == ^user_id,
      select: sub.source_id
    )
    |> Paginator.paginate(opts)
  end

  def list_users_following_tag_ids_paginated(tag_id, opts) do
    from(
      sub in TagSubscription,
      where: sub.source_id == ^tag_id,
      select: sub.user_id
    )
    |> Paginator.paginate(opts)
  end

  def list_subscribed_tags_paginated(user_id, opts) do
    from(
      sub in TagSubscription,
      where: sub.user_id == ^user_id,
      left_join: tag in assoc(sub, :source),
      select: tag
    )
    |> Paginator.paginate(opts)
  end

  def list_subscribed_tags(user_id) do
    from(
      sub in TagSubscription,
      where: sub.user_id == ^user_id,
      left_join: tag in assoc(sub, :source),
      select: tag
    )
    |> Repo.all()
  end

  def list_users_following_tag_paginated(tag_id, opts) do
    from(
      sub in TagSubscription,
      where: sub.source_id == ^tag_id,
      left_join: user in assoc(sub, :user),
      select: user
    )
    |> Paginator.paginate(opts)
  end

  def create_block(attrs \\ %{}) do
    block = TagBlock.create_changeset(%TagBlock{}, attrs)
    Repo.insert(block)
  end

  def delete_block(user_id, tag_id) do
    block = Repo.get_by(TagBlock, %{user_id: user_id, tag_id: tag_id})

    if(not is_nil(block)) do
      Repo.delete(block)
    end
  end
end
