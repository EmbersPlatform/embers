defmodule Embers.Links.Provider do
  @moduledoc """
  Defines a Provider behavior that can be implemented to extract metadata from
  specific websites, such as youtube or twitter.
  """

  @doc """
  Predicate function that checks if the provicer can process the url
  """
  @callback provides?(String.t()) :: boolean()

  @doc """
  Extracts data from a URL
  """
  @callback get(String.t()) :: Embers.Links.EmbedSchema.t()
end
