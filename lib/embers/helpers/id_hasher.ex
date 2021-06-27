defmodule Embers.Helpers.IdHasher do
  @moduledoc """
  A wrapper around the `Hashids` library.

  Embers uses sequential, autoincremented ids. To prevent enumeration *attacks*,
  and avoid using UUIDs or Snowflakes, every id SHOULD be encoded before sending
  it to the client. This might change in the future, when the need for UUIDs or
  Snowflakes is properly addressed.

  Refer to the `Hashids` library for the `encode` and `decode` functions docs.
  """
  @coder Hashids.new(
           salt: "HmPbtapoe1FGfTFbEEeZcWKuakIQp3L0",
           min_en: 2
         )

  def encode(data) do
    Hashids.encode(@coder, data)
  end

  def decode(data) when is_nil(data), do: nil

  def decode(data) do
    # Hashids returns decoded id as a list
    # If the list has more than one element, the encoded id is malformed and
    # must be discarded
    # Maybe it should `raise` here?
    case Hashids.decode!(@coder, data) do
      [decoded] -> decoded
      [_h | _t] -> nil
    end
  end
end
