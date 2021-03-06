defmodule EmbersWeb.Api.FeedView do
  @moduledoc false

  use EmbersWeb, :view
  alias EmbersWeb.Api.PostView

  def render("timeline.json", %{entries: posts} = metadata) do
    %{
      items:
        Enum.map(posts, fn post ->
          render(
            PostView,
            "show.json",
            %{post: post, current_user: metadata.current_user}
          )
        end),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("posts.json", %{entries: posts} = metadata) do
    %{
      items:
        Enum.map(posts, fn post ->
          render(
            PostView,
            "show.json",
            %{post: post, current_user: metadata.current_user}
          )
        end),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("activity.json", %{activity: activity, current_user: current_user}) do
    render(PostView, "show.json", %{post: activity.post, current_user: current_user})
  end
end
