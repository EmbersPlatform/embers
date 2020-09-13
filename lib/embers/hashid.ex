defmodule Embers.Hashid do
  @behaviour Ecto.Type

  alias Embers.Helpers.IdHasher

  def type(), do: :id

  def cast(int) when is_integer(int) do
    {:ok, IdHasher.encode(int)}
  end

  def cast(id) when is_binary(id) do
    {:ok, id}
  end

  def cast(other) do
    :error
  end

  def dump(id) when is_binary(id) do
    case IdHasher.decode(id) do
      id when is_integer(id) -> {:ok, id}
      _ -> :error
    end
  end

  def load(id) when is_integer(id) do
    {:ok, IdHasher.encode(id)}
  end

end
