defmodule Embers.OpenGraph.Provider do
  @callback provides?(String.t()) :: boolean
  @callback get(String.t()) :: Embers.OpenGraph.OpenGraphData.t()
end
