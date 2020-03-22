defmodule Embers.Feed.Utils do
  alias Embers.Posts.Post

  def fill_nsfw(page) do
    Map.update!(page, :entries, fn posts ->
      Enum.map(posts, &Post.fill_nsfw/1)
    end)
  end

  def load_avatars(page) do
    Map.update!(page, :entries, fn posts ->
      Enum.map(posts, fn post ->
        update_in(post.user.meta, &Embers.Profile.Meta.load_avatar_map/1)
      end)
    end)
  end
end
