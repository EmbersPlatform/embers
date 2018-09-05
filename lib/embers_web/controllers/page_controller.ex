defmodule EmbersWeb.PageController do
  use EmbersWeb, :controller

  alias Embers.Repo
  alias Embers.Accounts.User

  def index(%Plug.Conn{assigns: %{current_user: nil}} = conn, params) do
    if is_nil(params["path"]) do
      conn = put_layout(conn, false)
      render(conn, "landing.html")
    else
      render(conn, "index.html")
    end
  end

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _params) do
    user =
      User
      |> Repo.get(current_user.id)
      |> Repo.preload([:meta, :settings])

    user = %{user | meta: user.meta |> Embers.Profile.Meta.load_avatar_map()}

    IO.inspect(user)

    render(conn, "index.html", user: user)
  end
end
