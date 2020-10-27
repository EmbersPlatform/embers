defmodule Embers.Paginator.Options do
  @moduledoc false

  @type t() :: %__MODULE__{
          before: any(),
          after: any(),
          limit: integer(),
          max_limit: integer(),
          inclusive_cursor: boolean()
        }
  defstruct before: nil,
            after: nil,
            limit: 20,
            max_limit: 100,
            inclusive_cursor: true

  @spec build(keyword()) :: Embers.Paginator.Options.t()
  def build(opts \\ []) do
    opts =
      struct(__MODULE__, %{
        after: Keyword.get(opts, :after),
        before: Keyword.get(opts, :before),
        limit: Keyword.get(opts, :limit),
        inclusive_cursor: Keyword.get(opts, :inclusive_cursor)
      })

    opts =
      if is_binary(opts.limit) do
        %{opts | limit: String.to_integer(opts.limit)}
      end || opts

    opts =
      if is_nil(opts.limit) do
        %{opts | limit: 20}
      end || opts

    opts =
      if opts.limit > opts.max_limit do
        %{opts | limit: opts.max_limit}
      end || opts

    opts =
      if is_nil(opts.inclusive_cursor) do
        %{opts | inclusive_cursor: true}
      end || opts

    opts
  end
end
