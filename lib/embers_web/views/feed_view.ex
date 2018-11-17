defmodule EmbersWeb.FeedView do
  use EmbersWeb, :view
  alias EmbersWeb.PostView

  def render("timeline.json", %{entries: activities} = metadata) do
    %{
      items: render_many(activities, __MODULE__, "activity.json", as: :activity),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("posts.json", %{entries: posts} = metadata) do
    %{
      items: render_many(posts, EmbersWeb.PostView, "post.json", as: :post),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("activity.json", %{activity: activity}) do
    render_one(activity.post, PostView, "post.json")
  end
end
