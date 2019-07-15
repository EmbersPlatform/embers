defmodule Embers.Feed do
  @moduledoc """
  El modulo para interactuar con los feeds
  """
  @callback get(keyword) :: Embers.Paginator.Page.t()
end
