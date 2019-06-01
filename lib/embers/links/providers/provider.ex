defmodule Embers.Links.Provider do
  @callback provides?(String.t()) :: boolean()
  @callback get(String.t()) :: Embers.Links.EmbedSchema.t()
end
