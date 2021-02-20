defmodule EmbersWeb.TagController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Tags

  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.FallbackController)

  plug(:accepts, ~w(html json))

  plug(CheckPermissions, [permission: "access_mod_tools"] when action in [:update])

  def show(conn, %{"name" => name} = params) do
    tag =
      case Tags.get_by_name(name) do
        nil -> %Tags.Tag{name: name, description: nil}
        tag -> tag
      end

    page =
      if is_nil(tag.id) do
        Embers.Paginator.Page.empty()
      else
        Tags.list_tag_posts(tag.name, before: params["before"], limit: params["limit"])
      end

    conn =
      conn
      |> assign(:page, page)
      |> assign_sub_level(tag)

    if params["entries"] == "true" do
      conn
      |> put_layout(false)
      |> Embers.Paginator.put_page_headers(page)
      |> render("entries.html")
    else
      conn
      |> render(:show, tag: tag)
    end
  end

  defp assign_sub_level(conn, tag) do
    if is_nil(conn.assigns.current_user) do
      conn
    else
      sub_level = Embers.Subscriptions.Tags.get_sub_level(conn.assigns.current_user.id, tag.id)

      assign(conn, :sub_level, sub_level)
    end
  end

  def list_popular(conn, _params) do
    popular = Tags.get_popular_tags(limit: 5)

    conn
    |> render("popular.json", popular: popular)
  end

  def list_hot(conn, _params) do
    hot = Tags.get_hot_tags(limit: 5)

    conn
    |> render("hot.json", hot: hot)
  end

  def update(conn, %{"id" => id} = params) do
    with tag when not is_nil(tag) <- Tags.get_by(%{id: id}),
         attrs = Map.take(params, ["name", "description"]),
         {:ok, updated_tag} <- Tags.update_tag(tag, attrs) do
      render(conn, "tag.json", tag: updated_tag)
    end
  end
end
