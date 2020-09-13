defmodule EmbersWeb.Web.Moderation.TagController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Posts
  alias Embers.Tags
  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(CheckPermissions, [permission: "update_post"] when action in [:update_tags])

  def update_tags(conn, %{"post_id" => post_id, "tag_names" => tag_names}) do
    tag_names = Enum.filter(tag_names, &Tags.Tag.valid_name?/1)

    with post <- post_id |> Posts.get_post!() |> Embers.Repo.preload(:tags) do
      Tags.update_tags(post, tag_names)
      post = post_id |> Posts.get_post!() |> Embers.Repo.preload(:tags)

      new_tags = Enum.map(post.tags, fn x -> x.name end)
      EmbersWeb.Endpoint.broadcast!("post:#{post_id}", "tags_updated", %{new_tags: new_tags})

      conn
      |> put_layout(false)
      |> put_view(EmbersWeb.Web.PostView)
      |> render("post.html", post: post)
    end
  end
end
