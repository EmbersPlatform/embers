defmodule EmbersWeb.Web.Moderation.UserController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Accounts

  def index(conn, _params) do
    roles = Embers.Authorization.Roles.list_all()

    conn
    |> assign(:roles, roles)
    |> render("index.html", page_title: gettext("Users"))
  end

  def list_users(conn, params) do
    opts = [
      before: params["before"],
      order: :desc,
      preloads: [:roles],
      filters: []
    ]

    opts =
      Keyword.update!(opts, :filters, fn filters ->
        filters =
          if not is_nil(params["canonical"]) do
            Keyword.put(filters, :canonical, params["canonical"])
          end || filters

        filters =
          if not is_nil(params["email"]) do
            Keyword.put(filters, :email, params["email"])
          end || filters

        filters
      end)

    page = Accounts.list_users_paginated(opts)

    render(conn, "users.json", page: page)
  end

  def update(conn, %{"user_id" => user_id} = params) do
    with %{} = user <- Accounts.get_populated(user_id),
         {user_data, new_roles} <- parse_update_params(params),
         {:ok, _} <- Accounts.update_user(user, user_data, roles: new_roles) do
      user = Accounts.get_populated(user_id) |> Embers.Repo.preload(:roles)
      render(conn, "user.json", user: user)
    end
  end

  defp parse_update_params(params) do
    user_data = Map.take(params, ["username", "email", "bio"])
    new_roles = Map.get(params, "roles", [])

    {user_data, new_roles}
  end

  def remove_avatar(conn, %{"user_id" => user_id}) do
    with meta when not is_nil(meta) <- Embers.Profile.get_meta_for(user_id),
         :ok <- Embers.Profile.remove_avatar(meta),
         meta <- Embers.Profile.get_meta_for(user_id),
         meta <- Embers.Profile.Meta.load_avatar_map(meta) do
      conn
      |> json(meta.avatar)
    end
  end

  def remove_cover(conn, %{"user_id" => user_id}) do
    with meta <- Embers.Profile.get_meta_for(user_id),
         :ok <- Embers.Profile.remove_cover(meta),
         meta <- Embers.Profile.get_meta_for(user_id),
         meta <- Embers.Profile.Meta.load_cover(meta) do
      conn
      |> json(meta.cover)
    end
  end
end
