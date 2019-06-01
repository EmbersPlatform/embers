defmodule EmbersWeb.ModerationController do
  use EmbersWeb, :controller

  import Embers.Helpers.IdHasher

  alias Embers.Moderation
  alias Embers.{Feed, Repo, Tags}
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "ban_user"] when action in [:ban_user])
  plug(CheckPermissions, [permission: "update_post"] when action in [:update_tags])

  def ban_user(conn, %{"user_id" => id, "duration" => duration, "reason" => reason} = _params) do
    with user <- Embers.Accounts.get_user(decode(id)),
         {:ok, _ban} <- Moderation.ban_user(user, duration: duration, reason: reason) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end

  def update_tags(conn, %{"post_id" => post_id, "tag_names" => tag_names}) do
    post_id = decode(post_id)

    with post <- post_id |> Feed.get_post!() |> Repo.preload(:tags) do
      Tags.update_tags(post, tag_names)
      post = post_id |> Feed.get_post!() |> Repo.preload(:tags)

      conn
      |> put_view(EmbersWeb.PostView)
      |> render("show.json", post: post)
    end
  end
end
