defmodule Embers.Helpers.IdHasher do
  @moduledoc """
  Modulo para hashear Ids utilizando la librería `Hashids`.

  Dado que Embers usa ids secuenciales, es facil hacer *ataques* de
  enumeración de contenidos.
  Por ejemplo, si un usuario tiene id 23, se puede deducir que existen otros 22
  usuarios y que los siguientes seran 24, 25, 26... lo cual permite a un
  tercero tener un listado de todos los usuarios existentes.

  Esto es lo que se usaba en el archivo de posts eliminados de taringa, ya
  que antes de la V7 usaban ids secuenciales encodeados en base64, como el
  backend `fenix` de embers. Se anticipaban los ids de los posts aun sin
  crear para revisar periodicamente la página y cachear los posts antes de
  que sean eliminados.

  Si el id no es secuencial y no revela información adicional a un tercero,
  se puede evitar este *ataque*.
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
    [decoded] = Hashids.decode!(@coder, data)
    decoded
  end
end
