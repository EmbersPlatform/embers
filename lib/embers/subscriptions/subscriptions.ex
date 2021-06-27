defmodule Embers.Subscriptions do
  @moduledoc """
  Subscriptions are relationships between users and users or users and posts.
  This module focuses on the relationships between users. For relationships
  with other kind of entities, see the docs for sibling modules such as
  `Embers.Subscriptions.Tags`

  Subscriptions are modelled after a `subscriptor`(whoever wants to receive
  content) and a `source`.
  A subscriptor is always an user, but a source can be a user, a tag, or any
  other entity of interest.

  For instance, to follow an user you would subscribe to it, and you will start
  receiving their new posts in your own feed. The same happens when subscribing
  to a tag. Although it's not the tag that produces content but a user, in
  practical terms we can consider the content as being produced by the tag.
  """

  import Ecto.Query

  use Embers.PubSubBroadcaster

  alias Embers.Subscriptions.UserSubscription
  alias Embers.Paginator
  alias Embers.Repo

  @type events :: {:user, :followed}

  def get(id) do
    UserSubscription
    |> where([s], s.id == ^id)
    |> Repo.one()
  end

  @doc """
  Returns the list of users the user is subscribed to.

  ## Examples

      iex> list_user_subscriptions(user_id)
      [%UserSubscription{}, ...]

  """
  def list_user_subscriptions(user_id) do
    UserSubscription
    |> Repo.get_by(user_id: user_id)
  end

  @doc """
  Creates a subscription

  ## Examples

      iex> create_user_subscription(%{field: value})
      {:ok, %UserSubscription{}}

      iex> create_user_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_subscription(attrs) do
    subscription = UserSubscription.changeset(%UserSubscription{}, attrs)
    result = Repo.insert(subscription)

    broadcast({:user, :followed}, %{
      from: attrs.user_id,
      recipient: attrs.source_id
    })

    result
  end

  @doc """
  Deletes a user_subscription.

  ## Examples

      iex> delete_user_subscription(subscription)
      {:ok, %UserSubscription{}}

      iex> delete_user_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_subscription(user_id, source_id) do
    sub = Repo.get_by(UserSubscription, %{user_id: user_id, source_id: source_id})

    unless is_nil(sub) do
      Repo.delete(sub)
    end
  end

  @spec list_following_paginated(integer(), keyword()) :: Embers.Paginator.Page.t()
  def list_following_paginated(user_id, opts \\ []) do
    from(
      sub in UserSubscription,
      where: sub.user_id == ^user_id,
      left_join: user in assoc(sub, :source),
      left_join: meta in assoc(user, :meta),
      order_by: [desc: sub.id],
      preload: [
        user: {user, meta: meta}
      ]
    )
    |> Paginator.paginate(opts)
    |> Paginator.map(&load_sub_profile/1)
  end

  @spec list_following_ids_paginated(integer(), keyword()) :: Embers.Paginator.Page.t()
  def list_following_ids_paginated(user_id, opts \\ []) do
    UserSubscription
    |> where([sub], sub.user_id == ^user_id)
    |> select([sub], sub.source_id)
    |> Paginator.paginate(opts)
  end

  def list_followers_paginated(user_id, opts \\ []) do
    from(
      sub in UserSubscription,
      where: sub.source_id == ^user_id,
      left_join: user in assoc(sub, :user),
      left_join: meta in assoc(user, :meta),
      order_by: [desc: sub.id],
      preload: [
        user: {user, meta: meta}
      ]
    )
    |> Paginator.paginate(opts)
    |> Paginator.map(&load_sub_profile/1)
  end

  @spec list_followers_ids_paginated(integer(), keyword()) :: Embers.Paginator.Page.t()
  def list_followers_ids_paginated(user_id, opts \\ []) do
    UserSubscription
    |> where([sub], sub.source_id == ^user_id)
    |> select([sub], sub.user_id)
    |> Paginator.paginate(opts)
  end

  def list_followers_ids(user_id) do
    UserSubscription
    |> where([sub], sub.source_id == ^user_id)
    |> select([sub], sub.user_id)
    |> Repo.all()
  end

  def list_mutuals_ids(user_id) do
    followers =
      Repo.all(
        from(
          subscription in UserSubscription,
          where: subscription.user_id == ^user_id,
          select: subscription.source_id
        )
      )

    followed =
      Repo.all(
        from(
          subscription in UserSubscription,
          where: subscription.source_id == ^user_id,
          select: subscription.user_id
        )
      )

    intersection = MapSet.intersection(MapSet.new(followers), MapSet.new(followed))

    intersection
  end

  defp load_sub_profile(sub) do
    sub = update_in(sub.user.meta, &Embers.Profile.Meta.load_avatar_map/1)
    sub = update_in(sub.user.meta, &Embers.Profile.Meta.load_cover/1)
    sub
  end
end
