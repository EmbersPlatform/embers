defmodule Embers.Tasks do
  @moduledoc false

  defdelegate migrate(args), to: __MODULE__.Migrate
end
