defmodule EmbersWeb.Api.ModerationController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Moderation
  alias Embers.{Posts, Repo, Tags}
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "ban_user"] when action in [:ban_user])
  plug(CheckPermissions, [permission: "update_post"] when action in [:update_tags])

  def ban_user(conn, %{"user_id" => user_id, "duration" => duration, "reason" => reason} = params) do
    with user <- Embers.Accounts.get_user(user_id),
         {:ok, _ban} <-
           Moderation.ban_user(user,
             duration: duration,
             reason: reason,
             actor: conn.assigns.current_user.id
           ) do
      delete_since = Map.get(params, "delete_content_since")

      with false = is_nil(delete_since),
           {delete_since, _} = Integer.parse(delete_since) do
        Posts.bulk_delete_after_date(user_id, delete_since)
      end

      conn
      |> put_status(:no_content)
      |> json(nil)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end

  def update_tags(conn, %{"post_id" => post_id, "tag_names" => tag_names}) do
    with post <- post_id |> Posts.get_post!() |> Repo.preload(:tags) do
      Tags.update_tags(post, tag_names)
      post = post_id |> Posts.get_post!() |> Repo.preload(:tags)

      conn
      |> put_view(EmbersWeb.Web.PostView)
      |> render("show.json", post: post)
    end
  end
end
