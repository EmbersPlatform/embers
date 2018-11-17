defmodule EmbersWeb.PostView do
  use EmbersWeb, :view

  alias EmbersWeb.{PostView, UserView, MediaView}
  alias Embers.Helpers.IdHasher

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("post.json", %{post: post}) do
    view = %{
      id: IdHasher.encode(post.id),
      body: post.body,
      stats: %{
        replies: post.replies_count,
        shares: post.shares_count
      },
      nesting_level: post.nesting_level
    }

    view =
      if not is_nil(post.parent_id) do
        Map.put(view, "in_reply_to", IdHasher.encode(post.parent_id))
      else
        view
      end

    view =
      if Ecto.assoc_loaded?(post.user) do
        Map.put(view, "user", render_one(post.user, UserView, "user.json"))
      else
        view
      end

    view =
      if(Ecto.assoc_loaded?(post.media)) do
        Map.put(view, "media", render_many(post.media, MediaView, "media.json", as: :media))
      else
        view
      end

    view
  end

  def render("show_replies.json", %{entries: replies} = metadata) do
    %{
      items: render_many(replies, __MODULE__, "post.json", as: :post),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end
end
