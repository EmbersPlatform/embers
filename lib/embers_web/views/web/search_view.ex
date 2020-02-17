defmodule EmbersWeb.SearchView do
  @moduledoc false

  use EmbersWeb, :view

  def render("results.json", %{entries: posts} = metadata) do
    %{
      items:
        Enum.map(posts, fn post ->
          render(
            EmbersWeb.PostView,
            "show.json",
            %{post: post, current_user: metadata.current_user}
          )
        end),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  def render("user_results.json", %{results: results}) do
    render_many(results, EmbersWeb.UserView, "user.json")
  end
end
