defmodule Embers.Feed.Utils do
  alias Embers.Posts.Post

  def fill_nsfw(page) do
    Map.update!(page, :entries, fn posts ->
      Enum.map(posts, &Post.fill_nsfw/1)
    end)
  end

  def load_avatars(%Embers.Paginator.Page{} = page) do
    Map.update!(page, :entries, &load_avatars/1)
  end

  def load_avatars(posts) when is_list(posts) do
    Enum.map(posts, fn post ->
      update_in(post.user.meta, &Embers.Profile.Meta.load_avatar_map/1)
      |> update_replies_avatars()
      |> update_related_avatar()
    end)
  end

  defp update_replies_avatars(post) do
    if Ecto.assoc_loaded?(post.replies) do
      update_in(post.replies, &load_avatars/1)
    else
      post
    end
  end

  defp update_related_avatar(post) do
    if Ecto.assoc_loaded?(post.related_to) and post.related_to do
      update_in(post.related_to.user.meta, &Embers.Profile.Meta.load_avatar_map/1)
    else
      post
    end
  end
end
