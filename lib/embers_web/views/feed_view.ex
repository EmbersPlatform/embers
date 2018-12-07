defmodule EmbersWeb.FeedView do
  use EmbersWeb, :view
  alias EmbersWeb.PostView

  def render("timeline.json", %{entries: activities} = metadata) do
    %{
      items:
        Enum.map(activities, fn activity ->
          render(__MODULE__, "activity.json", %{
            activity: activity,
            current_user: metadata.current_user
          })
        end),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("posts.json", %{entries: posts} = metadata) do
    %{
      items: render_many(posts, EmbersWeb.PostView, "show.json", as: :post),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("activity.json", %{activity: activity, current_user: current_user}) do
    render(PostView, "show.json", %{post: activity.post, current_user: current_user})
  end
end
