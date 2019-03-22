defmodule Embers.Paginator.Page do
  @type t() :: %__MODULE__{
    entries: list(),
    last_page: boolean(),
    next: String.t()
  }
  @enforce_keys [:entries, :last_page, :next]
  defstruct entries: [],
            last_page: true,
            next: nil
end
