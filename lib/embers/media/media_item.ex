defmodule Embers.Media.MediaItem do
  @moduledoc """
  Esta es la representacion del medio en la base de datos.

  Un medio tiene al menos una url y un tipo. El tipo puede ser `image`, `gif`,
  `video` o `link`.
  También posee un campo `:temporary` para indicar si el medio es temporal
  o no.

  El campo `:metadata` se utiliza para guardar informacion adicional
  denormalizada. Ejemplos de esto serian el alto, ancho, tamaño, o cualquier
  otra informacion que podria ser útil. Está pensado principalmente para que
  los clientes puedan manejar mejor su representación, ya que el tipo de medio
  no siempre es suficiente.
  Lo ideal sería guardar siempre el ancho y alto del medio, la duracion si es
  un video, y el titulo + descripcion si es un link.

  El punto de que los metadatos sea denormalizado es para no tener que cambiar
  la estructura de la base de datos cada vez que se decida manejarlos de manera
  distinta.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @valid_types ~w(image gif video link)

  schema "media_items" do
    field(:url, :string, null: false)
    field(:type, :string, null: false)
    field(:temporary, :boolean, default: true)
    field(:metadata, {:map, :any})

    belongs_to(:user, Embers.Accounts.User)

    many_to_many(:post, Embers.Posts.Post, join_through: "posts_medias")

    timestamps()
    field(:deleted_at, :naive_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:url, :type, :temporary, :user_id, :metadata])
    |> validate_required([:url, :type, :user_id])
    |> validate_inclusion(
      :type,
      @valid_types,
      message: "is not a valid media type, use one of: #{Enum.join(@valid_types, " ")}"
    )
  end
end
