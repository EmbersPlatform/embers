defmodule Embers.Feed.Favorites do
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

  def list_paginated(user_id, params \\ %{}) do
    from(fav in Favorite,
      as: :favorite,
      where: fav.user_id == ^user_id,
      order_by: [desc: fav.inserted_at]
    )
    |> with_post()
    |> Paginator.paginate(params)
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
