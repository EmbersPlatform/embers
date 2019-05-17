defmodule EmbersWeb.ReactionController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Helpers.IdHasher
  alias Embers.{Feed, Feed.Reactions}

  plug(:user_check when action in [:create, :delete])

  def create(conn, %{"name" => name, "post_id" => post_id} = _params) do
    user_id = conn.assigns.current_user.id
    post_id = IdHasher.decode(post_id)

    case Reactions.create_reaction(%{"name" => name, "user_id" => user_id, "post_id" => post_id}) do
      {:ok, _reaction} ->
        post = Feed.get_post!(post_id)

        conn
        |> put_view(EmbersWeb.PostView)
        |> render("show.json", %{post: post})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end

  def delete(conn, %{"name" => name, "post_id" => post_id}) do
    user_id = conn.assigns.current_user.id
    post_id = IdHasher.decode(post_id)

    Reactions.delete_reaction(%{
      "name" => name,
      "post_id" => post_id,
      "user_id" => user_id
    })

    post = Feed.get_post!(post_id)

    conn
    |> put_view(EmbersWeb.PostView)
    |> render("show.json", %{post: post})
  end

  def list_valid_reactions(conn, _parms) do
    reactions = Reactions.Reaction.valid_reactions
    conn
    |> json(reactions)
  end
end
