defmodule Embers.LoadingMsg do
  alias Embers.LoadingMsg.Msg
  alias Embers.Repo

  def get(id) when is_integer(id) do
    messages = list_all()
    Enum.find(messages, fn x -> x.id == id end)
  end

  def list_all() do
    Repo.all(Msg)
  end

  def get_random() do
    {_, messages} =
      Cachex.fetch(:embers, "loading_msg", fn _key ->
        list_all()
      end)

    if Enum.empty?(messages) do
      %Msg{title: "Cargando..."}
    else
      Enum.random(messages)
    end
  end

  def create(attrs) do
    msg = Msg.changeset(%Msg{}, attrs)

    case Repo.insert(msg) do
      {:ok, msg} ->
        bust_cache()
        {:ok, msg}

      error ->
        error
    end
  end

  def remove(id) when is_integer(id) do
    case get(id) do
      nil -> nil
      msg -> remove(msg)
    end
  end

  def remove(%Msg{} = msg) do
    bust_cache()
    Repo.delete(msg)
  end

  def update(id, attrs) when is_integer(id) do
    case get(id) do
      nil ->
        nil

      msg ->
        update(msg, attrs)
    end
  end

  def update(%Msg{} = msg, attrs) do
    msg = Msg.changeset(msg, attrs)
    bust_cache()
    Repo.update(msg)
  end

  defp bust_cache() do
    Cachex.del(:embers, "loading_msg")
  end
end
