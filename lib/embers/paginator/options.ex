defmodule Embers.Paginator.Options do
  @type t() :: %__MODULE__{
          before: any(),
          after: any(),
          limit: integer(),
          max_limit: integer()
        }
  defstruct before: nil,
            after: nil,
            limit: 50,
            max_limit: 100

  @spec build(keyword()) :: Embers.Paginator.Options.t()
  def build(opts \\ []) do
    opts =
      struct(__MODULE__, %{
        after: Keyword.get(opts, :after),
        before: Keyword.get(opts, :before),
        limit: Keyword.get(opts, :limit)
      })

    opts =
      if is_binary(opts.limit) do
        %{opts | limit: String.to_integer(opts.limit)}
      end || opts

    opts =
      if is_nil(opts.limit) do
        %{opts | limit: 50}
      end || opts

    opts =
      if opts.limit > opts.max_limit do
        %{opts | limit: opts.max_limit}
        opts
      end || opts

    opts
  end
end
