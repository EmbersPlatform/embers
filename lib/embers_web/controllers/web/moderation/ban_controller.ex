defmodule EmbersWeb.Web.Moderation.BanController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Accounts
  alias Embers.Moderation

  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(CheckPermissions, [permission: "ban_user"] when action in [:ban])

  def index(conn, params) do
    before = Map.get(params, "before")

    options = [before: before]

    bans = Moderation.list_all_bans(options)

    conn
    |> assign(:bans, bans)
    |> render("index.html")
  end

  def unban(conn, %{"user_id" => user_id}) do
    Moderation.unban_user(user_id)

    conn
    |> put_status(:no_content)
    |> json(nil)
  end

  @doc """
  Action for banning users
  """
  def ban(conn, %{"canonical" => canonical} = params) do
    actor = conn.assigns.current_user

    duration = Map.get(params, "duration", 1)
    reason = Map.get(params, "reason")

    IO.inspect(params)

    ban_opts = [
      duration: duration,
      reason: reason,
      actor: actor.id
    ]
    |> IO.inspect(label: "USER BANNED")

    with \
      %Accounts.User{} = user <- Accounts.get_by(%{"canonical" => canonical}),
      {:ok, _ban} <- Moderation.ban_user(user, ban_opts)
    do
      conn
      |> put_status(:no_content)
      |> json(nil)
    else
      {:error, :already_banned} ->
        conn
        |> put_status(:no_content)
        |> json(nil)
    end
  end
end
