defmodule EmbersWeb.PostView do
  use EmbersWeb, :view

  alias EmbersWeb.{PostView, UserView}

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    view = %{id: post.id, body: post.body, stats: []}

    view =
      if Ecto.assoc_loaded?(post.user) do
        Map.put(view, "user", render_one(post.user, UserView, "user.json"))
      else
        view
      end

    view
  end
end
