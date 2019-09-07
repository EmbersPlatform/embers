defmodule EmbersWeb.PostWebController do
  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Posts
  alias Embers.Profile.Meta

  plug(EmbersWeb.Plugs.InitialData)

  def show(%{assigns: %{current_user: nil}} = conn, %{"hash" => hash} = _params) do
    id = IdHasher.decode(hash)

    with {:ok, post } = Posts.get_post(id) do
      post = %{
        post |
        id: hash,
        user: %{
          post.user | meta: %{
            post.user.meta | avatar: Meta.avatar_map(post.user.meta)
          }
        }
      }

      og_metatags = build_metatags(post)

      conn
      |> render("show.html", post: post, og_metatags: og_metatags)
    end
  end
  def show(conn, _params) do
    conn
    |> render("index.html")
  end

  defp build_metatags(post) do
    metatags = [
      {"title", "#{post.body} - @#{post.user.username} en Embers"},
      {"description", post.body},
      {"type", "article"}
    ]

    images =
      for media <- post.media do
        {"image", media.url}
      end

    metatags = [metatags | images]

    metatags
  end
end
