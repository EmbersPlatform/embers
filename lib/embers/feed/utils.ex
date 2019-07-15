defmodule Embers.Feed.Utils do
  alias Embers.Posts.Post

  def fill_nsfw(page) do
    %{
      page
      | entries: Enum.map(page.entries, fn post -> Post.fill_nsfw(post) end)
    }
  end
end
