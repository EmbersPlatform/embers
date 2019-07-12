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

  Notification types are validated against a `@valid_types` list in `Embers.Notifications.Notification` module(wich is where the `Notification` schema is defined)
  """

  alias Embers.Notifications.Notification
  alias Embers.Paginator
  alias Embers.Repo

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
    changeset = Notification.create_changeset(%Notification{}, attrs)
    Repo.insert(changeset)
  end

  @doc """
  Inserts a notification with `attrs` for the given `recipients` *in a single
  query*

  TODO validate `attrs`
  """
  @spec batch_create_notification(list(), Keyword.t()) :: {any(), nil | [any()]}
  def batch_create_notification(recipients, attrs) do
    notifications =
      Enum.map(recipients, fn elem ->
        %{
          recipient_id: elem,
          type: attrs[:type],
          from_id: attrs[:from_id],
          source_id: attrs[:source_id],
          text: attrs[:text],
          status: attrs[:status] || 0
        }
      end)

    Repo.insert_all(Notification, notifications)
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

    unless is_nil(notification) do
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
  def list_notifications_paginated(user_id, opts \\ []) when is_integer(user_id) do
    query =
      from(
        notif in Notification,
        where: notif.recipient_id == ^user_id,
        left_join: user in assoc(notif, :from),
        left_join: user_meta in assoc(user, :meta),
        order_by: [desc: notif.inserted_at],
        preload: [
          from: {user, meta: user_meta}
        ]
      )

    results = Paginator.paginate(query, opts)

    mark_as_read = Keyword.get(opts, :mark_as_read, false)

    results =
      if mark_as_read do
        ids = Enum.map(results.entries, fn o -> o.id end)
        set_status(ids, 1)

        %{
          results
          | entries: set_read_status(results.entries)
        }
      end || results

    results
  end

  @doc """
  Sets the `status` a notification with id `id` to `status`. Defaults to `read` status.

  ## Examples
      set_read(id, 0) // unseen
      set_read(id, 1) // seen
      set_read(id, 2) // read
  """
  def set_status(id, status \\ 2)

  def set_status(id, status) when is_integer(id) do
    Repo.update_all(
      from(
        notif in Notification,
        where: notif.id == ^id,
        update: [set: [status: ^status]]
      ),
      []
    )
  end

  def set_status(ids, status) when is_list(ids) do
    Repo.update_all(
      from(
        notif in Notification,
        where: notif.id in ^ids and notif.status < ^status,
        update: [set: [status: ^status]]
      ),
      []
    )
  end

  defp set_read_status(entries) do
    Enum.map(entries, fn o ->
      if o.status < 1 do
        %{o | status: 1}
      end || o
    end)
  end
end
