defmodule Embers.Notifications do
  @moduledoc """
  Notifications context

  A notification is an event that is sent to the user and stored, such as new comments, follows or mentions.

  A notification has the following members:
  - `:type` representing the notification type, meant to be used for correct frontend representation
  - `:from_id` the id of the emmiter user (optional)
  - `:recipient_id` the id of the target user
  - `:source_id` that points to the source of the event, if any(eg: a comment)
  - `:read` status, being `true` or `false`
  - `:text` if needed
  - timestamps `inserted_at` and `updated_at`

  Notification types are validated against a `@valid_types` list in `Embers.Feed.Notification` module(wich is where the `Notification` schema is defined)
  """

  alias Embers.Notifications.Notification
  alias Embers.Repo
  alias Embers.Paginator

  import Ecto.Query

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
      {:ok, %Embers.Notifications.Notification{}}

      iex> create_notification(%{"field" => bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_notification(map()) ::
          {:ok, Embers.Notifications.Notification.t()} | {:error, Ecto.Changeset.t()}
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
  @spec delete_notification(integer()) :: Embers.Notifications.Notification.t() | nil
  def delete_notification(id) do
    notification = get(id)

    if not is_nil(notification) do
      Repo.delete(notification)
    end

    notification
  end

  @doc """
  Returns a paginated list of notifications for the given `user_id`

  ## Examples
      iex> list_notifications_paginated(1)
      [entries: [%Notification{}, ...], ...]
  """
  def list_notifications_paginated(user_id, pagination_opts \\ %{}) when is_integer(user_id) do
    from(
      notif in Notification,
      where: notif.recipient_id == ^user_id,
      left_join: user in assoc(notif, :from),
      preload: [from: user]
    )
    |> Paginator.paginate(pagination_opts)
  end

  @doc """
  Sets the `read` status of a notification with id `id` to `boolean`

  ## Examples
      set_read(1, true)
      set_read(2, false)
  """
  @spec set_read(integer(), boolean()) :: Embers.Notifications.Notification.t()
  def set_read(id, read \\ true) do
    from(
      notif in Notification,
      where: notif.id == ^id,
      update: [set: [read: ^read]]
    )
    |> Repo.update_all(returning: [true])
  end
end
