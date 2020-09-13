defmodule EmbersWeb.Web.LinkController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Links

  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check when action in [:process])
  plug(CheckPermissions, [permission: "create_media"] when action in [:process])

  def process(conn, %{"url" => url}) do
    user = conn.assigns.current_user

    with {:ok, embed} <- Links.fetch(url),
         {:ok, link} <- Links.save(%{user_id: user.id, embed: embed}) do
      conn
      |> put_resp_header("embers-link-id", link.id)
      |> put_layout(false)
      |> render(:link, link: link)
    else
      {:error, :file_not_supported} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", error: gettext("Couldn't process link"))

      {:error, _error} ->
        conn
        |> put_status(500)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("500.json", error: gettext("Internal error"))
    end
  end
end
