defmodule Embers.Chat do
  @moduledoc """
  El chat de Embers.
  """
  import Ecto.Query

  alias Embers.Chat.Message
  alias Embers.Paginator
  alias Embers.Repo

  def create(attrs, opts \\ []) when is_map(attrs) do
    message =
      %Message{}
      |> Message.changeset(attrs)

    temp_id = Keyword.get(opts, :temp_id, nil)

    case Repo.insert(message) do
      {:ok, message} ->
        message = message |> Repo.preload(sender: :meta, receiver: :meta)
        Embers.Event.emit(:chat_message_created, %{message: message, temp_id: temp_id})
        {:ok, message}

      error ->
        error
    end
  end

  def read(%Message{} = message) do
    message
    |> Message.read_changeset()
    |> Repo.update()
  end

  def read_conversation(reader, party) do
    from(m in Message,
      where: m.receiver_id == ^reader and m.sender_id == ^party,
      update: [set: [read_at: ^DateTime.utc_now()]]
    )
    |> Repo.update_all([])
  end

  def list_messages_for(party1, party2, opts \\ []) do
    query =
      from(m in Message,
        where: m.sender_id == ^party1 and m.receiver_id == ^party2,
        or_where: m.sender_id == ^party2 and m.receiver_id == ^party1,
        order_by: [desc: m.inserted_at],
        preload: [sender: :meta]
      )

    Paginator.paginate(query, opts)
  end

  def list_conversations_with(%Embers.Accounts.User{id: user_id}) do
    list_conversations_with(user_id)
  end

  def list_unread_conversations(user_id) do
    from(m in Message,
      where: m.receiver_id == ^user_id,
      where: is_nil(m.read_at),
      group_by: m.sender_id,
      select: %{party: m.sender_id, unread: count(m.sender_id)}
    )
    |> Repo.all()
  end

  def list_conversations_with(user_id) when is_integer(user_id) do
    receivers =
      from(m in Message,
        where: m.sender_id == ^user_id,
        left_join: user in assoc(m, :receiver),
        left_join: meta in assoc(user, :meta),
        order_by: [desc: m.inserted_at],
        group_by: [user.id, meta.id, m.inserted_at],
        select: [m.inserted_at, user, meta]
      )
      |> Repo.all()
      |> Enum.map(fn [date, user, meta] ->
        [date, %{user | meta: meta}]
      end)

    senders =
      from(m in Message,
        where: m.receiver_id == ^user_id,
        left_join: user in assoc(m, :sender),
        left_join: meta in assoc(user, :meta),
        order_by: [desc: m.inserted_at],
        group_by: [user.id, meta.id, m.inserted_at],
        select: [m.inserted_at, user, meta]
      )
      |> Repo.all()
      |> Enum.map(fn [date, user, meta] ->
        [date, %{user | meta: meta}]
      end)

    Enum.concat(receivers, senders)
    |> Enum.uniq_by(fn [_date, user] -> user.id end)
    |> Enum.sort_by(fn [date, _user] -> date end)
    |> Enum.reverse()
    |> Enum.map(fn [date, user] -> %{user | inserted_at: date} end)
  end
end
