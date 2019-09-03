defmodule EmbersWeb.PostWebController do
  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Posts
  alias Embers.Profile.Meta

  plug(EmbersWeb.Plugs.InitialData)

  def show(%{assigns: %{current_user: nil}} = conn, %{"hash" => hash} = _params) do
    id = IdHasher.decode(hash)

    with {:ok, post} = Posts.get_post(id) do
      post = %{
        post
        | id: hash,
          user: %{
            post.user
            | meta: %{
                post.user.meta
                | avatar: Meta.avatar_map(post.user.meta)
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
    description = post.body

    title =
      if post.body do
        "#{post.body} - @#{post.user.username} en Embers"
      else
        "Post de @#{post.user.username} en Embers"
      end

    type =
      cond do
        length(post.media) == 1 ->
          Map.get(List.first(post.media), :type)

        length(post.media) > 0 ->
          "article"

        true ->
          "article"
      end

    medias =
      for media <- post.media do
        {media.type, media.url}
      end

    tags =
      for tag <- post.tags do
        tag.name
      end
      |> Enum.join(" ")

    metatags = [
      {"site_name", "embers.pw"},
      {"url", "https://www.embers.pw/post/#{post.id}"},
      {"title", title},
      {"description", description},
      {"type", type},
      {"tags", tags}
      | medias
    ]

    metatags
  end
end
