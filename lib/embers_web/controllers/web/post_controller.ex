defmodule EmbersWeb.Web.PostController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Helpers.IdHasher
  alias Embers.Posts
  alias Embers.Profile.Meta

  plug(:user_check when action in [:create])

  plug(
    :rate_limit_post_creation,
    [max_requests: 10, interval_seconds: 60] when action in [:create]
  )

  def rate_limit_post_creation(conn, options \\ []) do
    options = Keyword.merge(options, bucket_name: "post_creation:#{conn.assigns.current_user.id}")
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  def show(conn, %{"hash" => hash} = _params) do
    id = IdHasher.decode(hash)

    with {:ok, post} = Posts.get_post(id) do
      post = put_in(post.user.meta.avatar, Meta.avatar_map(post.user.meta))
      post = put_in(post.id, hash)

      %{entries: replies} = Posts.get_post_replies(id)
      conn
      |> render(:show, post: post, replies: replies)
    end
  end

  def create(%{assigns: %{current_user: user}} = conn, params) do
    params =
      params
      |> put_user_id(user.id)
      |> maybe_put_parent_id()
      |> maybe_put_related_to_id()
      |> maybe_put_medias()
      |> maybe_put_links()
      |> get_and_put_tags()

    with {:ok, post} <- Posts.create_post(params) do
      {view, key} =
        cond do
          not is_nil(post.parent_id) -> {:reply, :reply}
          true -> {:post, :post}
        end

      conn
      |> put_layout(false)
      |> render(view, [{key, post}])
    end
  end

  defp put_user_id(params, id) do
    Map.put(params, "user_id", id)
  end

  defp maybe_put_parent_id(%{"parent_id" => parent_id} = params) do
    parent_id = IdHasher.decode(parent_id)
    Map.put(params, "parent_id", parent_id)
  end

  defp maybe_put_parent_id(params), do: params

  defp maybe_put_related_to_id(%{"related_to_id" => related_to_id} = params) do
    related_to_id = IdHasher.decode(related_to_id)
    Map.put(params, "related_to_id", related_to_id)
  end

  defp maybe_put_related_to_id(params), do: params

  defp maybe_put_medias(%{"medias" => medias} = params) do
    medias =
      for media <- medias,
          %{"id" => id_hash} = media,
          id = IdHasher.decode(id_hash),
          media = Embers.Media.get(id) do
        media
      end

    Map.put(params, "media", medias)
  end

  defp maybe_put_medias(params), do: params

  defp maybe_put_links(%{"links" => links} = params) do
    links =
      for link <- links,
          %{"id" => id_hash} = link,
          id = IdHasher.decode(id_hash),
          link = Embers.Links.get_by(%{id: id}) do
        link
      end

    Map.put(params, "links", links)
  end

  defp maybe_put_links(params), do: params

  defp get_and_put_tags(params) do
    body = Map.get(params, "body") || ""
    body_tags = Posts.Post.parse_tags(body)
    provided_tags = Map.get(params, "tags", [])

    tag_names =
      Enum.concat(body_tags, provided_tags)
      |> Enum.reject(fn tag -> tag == "" end)
      |> Enum.uniq()
      |> Enum.take(10)

    tags =
      for name <- tag_names do
        Embers.Tags.create_tag(name)
      end

    Map.put(params, "tags", tags)
  end
end
