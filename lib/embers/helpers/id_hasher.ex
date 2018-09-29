defmodule Embers.Helpers.IdHasher do
  @moduledoc """
  This module abstracts away the id hashing algorithm

  It currently sets the coder salt and options and delegates functions to the Hashids library
  """
  @coder Hashids.new(
           salt: "HmPbtapoe1FGfTFbEEeZcWKuakIQp3L0",
           min_en: 2
         )
  def encode(data) do
    Hashids.encode(@coder, data)
  end

  def decode(data) do
    # Hashids returns decoded id as a list
    [decoded] = Hashids.decode!(@coder, data)
    decoded
  end
end
