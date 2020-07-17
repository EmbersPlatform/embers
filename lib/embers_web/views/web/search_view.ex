defmodule EmbersWeb.SearchView do
  @moduledoc false

  use EmbersWeb, :view

  def render("results.json", %{posts: posts} = assigns) do
    %{
      items:
        Enum.map(posts.entries, fn post ->
          render(
            EmbersWeb.PostView,
            "show.json",
            %{post: post, current_user: assigns.current_user}
          )
        end),
      next: posts.next,
      last_page: posts.last_page
    }
  end

  def render("user_results.json", %{results: results}) do
    render_many(results, EmbersWeb.UserView, "user.json")
  end
end
