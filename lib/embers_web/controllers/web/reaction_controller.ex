defmodule EmbersWeb.Web.ReactionController do
  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Reactions

  action_fallback(EmbersWeb.Web.FallbackController)

  def reactions_overview(conn, %{"hash" => post_id}) do
    post_id = IdHasher.decode(post_id)
    reactions = Reactions.overview(post_id)

    conn
    |> put_layout(false)
    |> render("overview.json", reactions: reactions)
  end

  def reactions_by_name(conn, %{"hash" => post_id, "reaction_name" => reaction_name} = params) do
    post_id = IdHasher.decode(post_id)
    next = IdHasher.decode(params["after"])

    reaction_name =
      unless reaction_name == "all" do
        reaction_name
      end

    page =
      Reactions.who_reacted(post_id, reaction: reaction_name, after: next)
      |> Embers.Helpers.Avatars.load_avatars()

    conn
    |> put_layout(false)
    |> Embers.Paginator.put_page_headers(page)
    |> render(:reactions, page: page)
  end
end
