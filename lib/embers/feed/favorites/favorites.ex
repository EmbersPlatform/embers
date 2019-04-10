defmodule Embers.Feed.Favorites do
  @moduledoc """
  Los favoritos son los contenidos que el usuario guardó para ver más tarde.

  Están implementados como una tabla pivote que relaciona a un post
  con un usuario.
  Para agregar o quitar un posts de los favoritos de un usuario, se debe
  crear o eliminar una entrada en la db con las funciones `create/2` y
  `delete/2`.

  Dado que los favoritos no son posts sino las entidades que representan la
  relación, al levantarlos de la db no traerán consigo al post en cuestión.
  Debe tenerse en cuenta esto ya que los métodos `create/1` y `delete/2`
  devuelven la entrada del favorito, no del post. Si se desea obetner el post,
  debe levantarse utilizando el campo `post_id` del favorito.
  """
  alias Embers.Feed.Favorite
  alias Embers.Repo
  alias Embers.Paginator

  import Ecto.Query

  def create(user_id, post_id) do
    favorite = Favorite.changeset(%Favorite{}, %{user_id: user_id, post_id: post_id})

    Repo.insert(favorite)
  end

  def delete(user_id, post_id) do
    fav = Repo.get_by(Favorite, %{user_id: user_id, post_id: post_id})

    if(not is_nil(fav)) do
      Repo.delete(fav)
    end
  end

  def list_paginated(user_id, opts \\ []) do
    from(fav in Favorite,
      as: :favorite,
      where: fav.user_id == ^user_id,
      order_by: [desc: fav.inserted_at]
    )
    |> with_post()
    |> Paginator.paginate(opts)
  end

  defp with_post(query) do
    from([favorite: fav] in query,
      left_join: post in assoc(fav, :post),
      as: :post,
      left_join: post_user in assoc(post, :user),
      left_join: post_user_meta in assoc(post_user, :meta),
      left_join: post_media in assoc(post, :media),
      left_join: post_tags in assoc(post, :tags),
      left_join: related in assoc(post, :related_to),
      left_join: related_user in assoc(related, :user),
      left_join: related_user_meta in assoc(related_user, :meta),
      left_join: related_media in assoc(related, :media),
      preload: [
        post: {
          post,
          user: {
            post_user,
            meta: post_user_meta
          },
          media: post_media,
          tags: post_tags,
          related_to: {
            related,
            media: related_media, user: {related_user, meta: related_user_meta}
          }
        }
      ]
    )
  end
end
