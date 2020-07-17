defmodule EmbersWeb.FeedView do
  @moduledoc false

  use EmbersWeb, :view
  alias EmbersWeb.PostView

  def render("timeline.json", %{page: page} = assigns) do
    %{
      items:
        Enum.map(page.entries, fn post ->
          render(
            EmbersWeb.PostView,
            "show.json",
            %{post: post, current_user: assigns.current_user}
          )
        end),
      next: page.next,
      last_page: page.last_page
    }
  end

  def render("posts.json", %{page: page} = assigns) do
    %{
      items:
        Enum.map(page.entries, fn post ->
          render(
            EmbersWeb.PostView,
            "show.json",
            %{post: post, current_user: assigns.current_user}
          )
        end),
      next: page.next,
      last_page: page.last_page
    }
  end

  def render("activity.json", %{activity: activity, current_user: current_user}) do
    render(PostView, "show.json", %{post: activity.post, current_user: current_user})
  end
end
