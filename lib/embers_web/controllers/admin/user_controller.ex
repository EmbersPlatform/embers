defmodule EmbersWeb.Admin.UserController do
  use EmbersWeb, :controller

  alias Embers.Accounts
  alias Embers.Accounts.User
  alias Embers.Helpers.IdHasher
  alias Embers.Repo
  import EmbersWeb.Helpers

  plug(:put_layout, "dashboard.html")

  def index(conn, params) do
    page =
      Accounts.list_users_paginated(
        after: IdHasher.decode(params["after"]),
        limit: params["limit"],
        name: params["name"],
        preload: [:roles, :meta]
      )

    page = %{
      page
      | entries: page.entries |> load_avatars
    }

    render(conn, "list.html",
      users: page.entries,
      next: page.next,
      last_page: page.last_page
    )
  end

  def edit(conn, %{"name" => name}) do
    user = Accounts.get_populated(name) |> Repo.preload(:roles)
    changeset = User.changeset(user, %{})

    roles = Embers.Authorization.Roles.list_all()

    render(conn, "edit.html", changeset: changeset, user: user, roles: roles)
  end

  def update(conn, %{"name" => name} = params) do
    IO.inspect(params)
    user = Accounts.get_populated(name) |> Repo.preload(:roles)

    with {:ok, _} <-
           Accounts.update_user(user, params["user"],
             roles: roles_list_to_int_list(params["user"]["roles"])
           ) do
      success(conn, "Usuario actualizado con exito", user_path(conn, :index))
    else
      {:error, changeset} ->
        roles = Embers.Authorization.Roles.list_all()

        conn
        |> put_flash(:error, "Hubo un error al actualizar al usuario")
        |> render("edit.html", changeset: changeset, user: user, roles: roles)
    end
  end

  defp roles_list_to_int_list(roles) do
    roles
    |> Enum.map(&String.to_integer(&1))
  end

  defp load_avatars(users) do
    Enum.map(users, fn user ->
      %{user | meta: user.meta |> Embers.Profile.Meta.load_avatar_map()}
    end)
  end
end
