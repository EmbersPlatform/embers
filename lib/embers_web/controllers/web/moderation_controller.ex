defmodule EmbersWeb.ModerationController do
  use EmbersWeb, :controller

  import Embers.Helpers.IdHasher

  alias Embers.Moderation
  alias Embers.{Audit, Posts, Repo, Tags}
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "ban_user"] when action in [:ban_user])
  plug(CheckPermissions, [permission: "update_post"] when action in [:update_tags])

  def ban_user(conn, %{"user_id" => id, "duration" => duration, "reason" => reason} = _params) do
    with user <- Embers.Accounts.get_user(decode(id)),
         {:ok, _ban} <-
           Moderation.ban_user(user,
             duration: duration,
             reason: reason,
             actor: conn.assigns.current_user.id
           ) do
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

    with %{tags: old_tags} = post <- post_id |> Posts.get_post!() |> Repo.preload(:tags) do
      Tags.update_tags(post, tag_names)
      post = post_id |> Posts.get_post!() |> Repo.preload(:tags)

      new_tags = for tag <- post.tags, do: tag.name
      old_tags = for tag <- old_tags, do: tag.name

      create_updated_tags_audit_entry(conn, post, new_tags, old_tags)

      conn
      |> put_view(EmbersWeb.PostView)
      |> render("show.json", post: post)
    end
  end

  def create_updated_tags_audit_entry(conn, post, new_tags, old_tags) do
    added_tags =
      (new_tags -- old_tags)
      |> Enum.join(", ")

    removed_tags =
      (old_tags -- new_tags)
      |> Enum.join(", ")

    details = [
      %{
        action: "in_post"
      }
    ]

    details =
      if String.downcase(added_tags) == "nsfw" && removed_tags == "" do
        details ++
          [
            %{
              action: "marked_as_nsfw"
            }
          ]
      else
        build_tags_details(details, added_tags, removed_tags)
      end

    Audit.create(%{
      user_id: conn.assigns.current_user.id,
      action: "tags_updated",
      source: "#{post.id}",
      details: details
    })
  end

  def build_tags_details(details, added_tags, removed_tags) do
    details =
      if added_tags != "" do
        details ++
          [
            %{
              action: "tags_added",
              description: added_tags
            }
          ]
      end || details

    details =
      if removed_tags != "" do
        details ++
          [
            %{
              action: "tags_removed",
              description: removed_tags
            }
          ]
      end || details

    details
  end
end
