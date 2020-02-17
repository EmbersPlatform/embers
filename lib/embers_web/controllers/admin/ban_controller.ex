defmodule EmbersWeb.Admin.BanController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Helpers

  alias Embers.Helpers.IdHasher
  alias Embers.Moderation

  plug(:put_layout, "dashboard.html")

  def index(conn, params) do
    page =
      Moderation.list_all_bans(
        after: IdHasher.decode(params["after"]),
        limit: params["limit"],
        name: params["name"]
      )

    page = %{
      page
      | entries:
          page.entries
          |> Enum.map(fn ban ->
            ban = ban |> Embers.Repo.preload(:user)

            expires =
              case ban.expires_at do
                nil -> "Indefinida"
                _ -> Timex.format!(ban.expires_at, "{D}/{0M}/{YYYY}")
              end

            %{ban | expires_at: expires}
          end)
    }

    render(conn, "list.html",
      bans: page.entries,
      next: page.next,
      last_page: page.last_page
    )
  end

  def show(conn, %{"user_id" => user_id}) do
    user_id = IdHasher.decode(user_id)

    case Embers.Accounts.get_user(user_id) do
      nil ->
        error(conn, "No se pudo encontrar el usuario", ban_path(conn, :index))

      user ->
        bans = Moderation.list_bans(user, deleted: true)
        active_ban = Moderation.get_active_ban(user.id)

        render(conn, "show.html",
          user: %{user | id: IdHasher.encode(user_id)},
          bans: bans,
          active_ban: active_ban
        )
    end
  end

  def delete(conn, %{"user_id" => user_id}) do
    user_id = IdHasher.decode(user_id)

    case Embers.Accounts.get_user(user_id) do
      nil ->
        error(conn, "No se pudo encontrar el usuario", ban_path(conn, :index))

      user ->
        with {:ok, _} <- Moderation.unban_user(user.id) do
          success(conn, "Suspension concluida con exito", ban_path(conn, :index))
        else
          {:error, _} ->
            error(conn, "Hubo un error al concluir la suspension", ban_path(conn, :index))
        end
    end
  end
end
