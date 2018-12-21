defmodule Embers.Notifications do
  @moduledoc """
  Notifications context

  A notification is an event that is sent to the user and stored, such as new comments, follows or mentions.

  A notification has the following members:
  - `:type` representing the notification type, meant to be used for correct frontend representation
  - `:user_id` from the emitter
  - `:source_id` that points to the source, if any(eg: a comment)
  - `:read` status, being `true` or `false`
  - `:text` if needed
  - timestamps `inserted_at` and `updated_at`

  Notification types are validated against a `@valid_types` list in `Embers.Feed.Notification` module(wich is where the `Notification` schema is defined)
  """

  alias Embers.Notifications.Notification
  alias Embers.Repo

  @doc """
  Returns a `Notification` by it's `:id` or `nil` if not found

  ## Examples

      iex> get(123)
      %Notification{}

      iex> get(456)
      nil
  """
  @spec get(integer()) :: Embers.Notifications.Notification.t() | nil
  def get(id) do
    Repo.get(Notification, id)
  end

  @doc """
  Returns a `Notification` by it's `:id` or raises if nor found

  ## Examples

      iex> get!(123)
      %Notification{}

      iex> get!(456)
      ** (Ecto.NoResultsError)
  """
  @spec get!(integer()) :: Embers.Notifications.Notification.t()
  def get!(id) do
    Repo.get!(Notification, id)
  end

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{"field" => value})
      {:ok, %Notification{}}

      iex> create_notification(%{"field" => bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_notification(map()) :: {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def create_notification(attrs) do
    Notification.create_changeset(%Notification{}, attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a notification by it's id and returns `Notification` or `nil`

  ## Examples
      iex> delete_notification(123)
      %Notification{}

      iex> delete_notification(456)
      nil
  """
  @spec delete_notification(integer()) :: Notification.t() | nil
  def delete_notification(id) do
    notification = get(id)

    if not is_nil(notification) do
      Repo.delete(notification)
    end

    notification
  end
end
