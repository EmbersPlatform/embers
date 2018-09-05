defmodule Embers.Feed.Subscriptions do
  @moduledoc """
  A module to interface with subscriptions
  """

  alias Embers.Feed.Subscriptions.UserSubscription
  alias Embers.Repo

  @doc """
  Returns the list of users the user is subscribed to.

  ## Examples

      iex> list_user_subscriptions(user_id)
      [%UserSubscription{}, ...]

  """
  def list_user_subscriptions(user_id) do
    Repo.get_by(UserSubscription, user_id: user_id)
  end

  @doc """
  Creates a subscription

  ## Examples

      iex> create_user_subscription(%{field: value})
      {:ok, %UserSubscription{}}

      iex> create_user_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_subscription(attrs \\ %{}) do
    %UserSubscription{}
    |> UserSubscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a user_subscription.

  ## Examples

      iex> delete_user_subscription(subscription)
      {:ok, %UserSubscription{}}

      iex> delete_user_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_subscription(%UserSubscription{} = subscription) do
    Repo.delete(subscription)
  end
end
