defmodule Embers.Feed.Subscriptions do
  @moduledoc """
  A module to interface with subscriptions
  """

  import Ecto.Query

  alias Embers.Feed.Subscriptions.{UserSubscription}
  alias Embers.Repo
  alias Embers.Paginator

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

    Embers.Event.emit(:user_followed, %{
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

    if(not is_nil(sub)) do
      Repo.delete(sub)
    end
  end

  @spec list_following_paginated(integer(), keyword()) :: Embers.Paginator.Page.t()
  def list_following_paginated(user_id, opts \\ []) do
    UserSubscription
    |> where([sub], sub.user_id == ^user_id)
    |> join(:left, [sub], user in assoc(sub, :source))
    |> join(:left, [sub, user], meta in assoc(user, :meta))
    |> preload([sub, user, meta], user: {user, meta: meta})
    |> Paginator.paginate(opts)
  end

  @spec list_following_ids_paginated(integer(), keyword()) :: Embers.Paginator.Page.t()
  def list_following_ids_paginated(user_id, opts \\ []) do
    UserSubscription
    |> where([sub], sub.user_id == ^user_id)
    |> select([sub], sub.source_id)
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
      from(
        subscription in UserSubscription,
        where: subscription.user_id == ^user_id,
        select: subscription.source_id
      )
      |> Repo.all()

    followed =
      from(
        subscription in UserSubscription,
        where: subscription.source_id == ^user_id,
        select: subscription.user_id
      )
      |> Repo.all()

    intersection = MapSet.intersection(MapSet.new(followers), MapSet.new(followed))

    intersection
  end
end
