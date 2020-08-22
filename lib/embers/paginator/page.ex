defmodule Embers.Paginator.Page do
  @moduledoc false

  @type t() :: %__MODULE__{
          entries: list(),
          last_page: boolean(),
          next: String.t()
        }
  @enforce_keys [:entries, :last_page, :next]
  defstruct entries: [],
            last_page: true,
            next: nil

  def empty(), do: %__MODULE__{entries: [], last_page: true, next: nil}

  defimpl Enumerable do
    def count(_page), do: {:error, __MODULE__}

    def member?(_page, _value), do: {:error, __MODULE__}

    def reduce(%{entries: entries}, acc, fun) do
      Enumerable.reduce(entries, acc, fun)
    end

    def slice(_page), do: {:error, __MODULE__}
  end

  defimpl Collectable do
    def into(original) do
      original_entries = original.entries
      impl = Collectable.impl_for(original_entries)
      {_, entries_fun} = impl.into(original_entries)

      fun = fn page, command ->
        %{page | entries: entries_fun.(page.entries, command)}
      end

      {original, fun}
    end
  end
end
