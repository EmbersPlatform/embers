defmodule Embers.Feed.Activity do
  @moduledoc """
  Una actividad es la unidad constitutiva de los feeds.

  Embers usa el método "fanout" para crear los feeds o timelines.
  Cada vez que se crea un post, se genera la lista de usuarios que deben
  recibir el post en su feed, y se crea una actividad por cada uno.

  Si bien se podria realizar una consulta para cada tipo de post en vez
  de crear una actividad por cada feed, surgen los siguientes problemas:

  - La consulta se vuelve lenta mientras mas seguidos tenga el usuario. Los
  joins y where ins no son operaciones computacionalmente baratas, por lo cual
  mantener la consulta lo más simple posible es fundamental para reducier los
  tiempos.
  - Hacer que un usuario pueda quitar un post de su feed se vuelve más
  complicado, haciéndose necesarias tablas adicionales donde se guardan
  los posts borrados. Es más difícil comprender el diseño.

  Se puede pensar en los feeds y actividades como correos y suscripciones.
  De hecho, la idea es la misma. Uno comienza a recibir posts desde el
  momento en que se suscribe. Si un post no le gusta, lo deshecha. Puede
  cancelar la suscripción en cualquier momento, pero los posts anteriores
  siguen disponibles.

  En el fondo, las actividades están implementadas como una tabla pivote
  relacionando a usuarios con posts.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "feed_activity" do
    belongs_to(:user, Embers.Accounts.User)
    belongs_to(:post, Embers.Feed.Post)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
  end
end
