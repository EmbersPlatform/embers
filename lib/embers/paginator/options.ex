defmodule Embers.Paginator.Options do
  defstruct before: nil,
            after: nil,
            limit: 50,
            max_limit: 500
end
