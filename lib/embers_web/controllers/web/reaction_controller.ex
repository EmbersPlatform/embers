defmodule EmbersWeb.ReactionController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  import Embers.Helpers.IdHasher
  alias Embers.Helpers.IdHasher
  alias Embers.{Posts, Reactions}

  plug(:user_check when action in [:create, :delete])

  plug(
    :rate_limit_create,
    [max_requests: 5, interval_seconds: 1] when action in [:create, :delete]
  )
  plug(
    :rate_limit_delete,
    [max_requests: 5, interval_seconds: 1] when action in [:create, :delete]
  )

  def rate_limit_create(conn, options \\ []) do
    user_id = conn.assigns.current_user.id
    options = Keyword.merge(options, bucket_name: "create_reaction:#{user_id}")
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  def rate_limit_delete(conn, options \\ []) do
    user_id = conn.assigns.current_user.id
    options = Keyword.merge(options, bucket_name: "delete_reaction:#{user_id}")
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  def create(conn, %{"name" => name, "post_id" => post_id} = _params) do
    user_id = conn.assigns.current_user.id
    post_id = IdHasher.decode(post_id)

    case Reactions.create_reaction(%{"name" => name, "user_id" => user_id, "post_id" => post_id}) do
      {:ok, _reaction} ->
        post = Posts.get_post!(post_id)

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

    post = Posts.get_post!(post_id)

    conn
    |> put_view(EmbersWeb.PostView)
    |> render("show.json", %{post: post})
  end

  def list_valid_reactions(conn, _parms) do
    reactions = Reactions.Reaction.valid_reactions()

    conn
    |> json(reactions)
  end

  def reactions_overview(conn, %{"post_id" => post_id}) do
    post_id = decode(post_id)
    stats = Reactions.overview(post_id)

    conn
    |> render("stats.json", stats: stats)
  end

  def reactions_by_name(conn, %{"post_id" => post_id, "reaction_name" => reaction_name} = params) do
    post_id = decode(post_id)

    reaction_name =
      unless reaction_name == "all" do
        reaction_name
      end

    reactions = Reactions.who_reacted(post_id, reaction: reaction_name, after: params["after"])

    conn
    |> render("reactions.json", reactions)
  end
end
