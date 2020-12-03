defmodule EmbersWeb.Web.Moderation.ReportsView do
  @moduledoc false

  use EmbersWeb, :view

  def render("comments.json", %{comments: comments}) do
    %{
      reasons: render_many(comments.entries, __MODULE__, "comment.json", as: :comment),
      next: comments.next,
      last_page: comments.last_page
    }
  end

  def render("comment.json", %{comment: comment}) do
    %{
      reporter: %{
        id: comment.reporter.id,
        username: comment.reporter.username
      },
      comments: comment.comments
    }
  end
end
