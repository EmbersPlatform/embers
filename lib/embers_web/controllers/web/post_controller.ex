defmodule EmbersWeb.PostController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Posts
  alias Embers.Helpers.IdHasher
  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.FallbackController)

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])
  plug(CheckPermissions, [permission: "create_post"] when action in [:create])

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    params =
      params
      |> put_user_id(user.id)
      |> maybe_put_parent_id()
      |> maybe_put_related_to_id()
      |> maybe_put_medias()
      |> maybe_put_links()
      |> get_and_put_tags()

    with {:ok, post} <- Posts.create_post(params) do
      conn
      |> render("show.json", post: post)
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

  def show(conn, %{"id" => id}) do
    post_id = IdHasher.decode(id)

    with {:ok, post} <- Posts.get_post(post_id) do
      post = populate_user(post, conn)

      render(conn, "show.json", %{post: post})
    else
      {:error, :post_disabled} ->
        conn |> json(:post_disabled)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render("show.json", %{post: nil})
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)
    post = Posts.get_post!(id)

    case can_delete?(user, post) do
      true ->
        {:ok, _post} = Posts.delete_post(post, actor: user.id)

      false ->
        conn |> put_status(:forbidden) |> json(nil)
    end

    render(conn, "show.json", post: post)
  end

  def show_replies(conn, %{"id" => parent_id} = params) do
    parent_id = IdHasher.decode(parent_id)

    order =
      case params["order"] do
        "desc" -> :desc
        "asc" -> :asc
        _ -> :asc
      end

    results =
      Posts.get_post_replies(parent_id,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"],
        order: order
      )

    render(conn, "show_replies.json", results)
  end

  defp can_delete?(user, post) do
    Embers.Authorization.is_owner?(user, post) || Embers.Authorization.can?("delete_post", user)
  end

  defp populate_user(nil, _), do: nil

  defp populate_user(post, %Plug.Conn{assigns: %{current_user: current_user}})
       when not is_nil(current_user) do
    %{
      post
      | user: Embers.Accounts.User.load_following_status(post.user, current_user.id)
    }
  end

  defp populate_user(post, _), do: post
end
