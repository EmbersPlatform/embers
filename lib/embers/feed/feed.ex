defmodule Embers.Feed do
  @moduledoc """
  Defines the behaviour all Feeds should implement
  """

  @callback get(options :: keyword) :: Embers.Paginator.Page.t()
end
