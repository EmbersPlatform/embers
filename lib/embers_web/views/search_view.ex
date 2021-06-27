defmodule EmbersWeb.SearchView do
  @moduledoc false

  use EmbersWeb, :view

  def render("search_results.json", %{page: page} = assigns) do
    %{
      body: raw(render_many(page.entries, EmbersWeb.PostView, "post.html", assigns)),
      next: page.next,
      last_page: page.last_page
    }
  end

  def render("user_results.json", %{results: results}) do
    render_many(results, EmbersWeb.UserView, "user.json")
  end
end
