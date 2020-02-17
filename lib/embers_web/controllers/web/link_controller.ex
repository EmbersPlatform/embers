defmodule EmbersWeb.LinkController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Links
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "create_media"] when action in [:parse])

  def parse(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"url" => url}) do
    with {:ok, embed} <- Links.fetch(url),
         {:ok, link} <- Links.save(%{user_id: user.id, embed: embed}) do
      conn
      |> render("link.json", link: link)
    else
      {:error, :file_not_supported} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", error: gettext("Couldn't process link"))

      {:error, _error} ->
        conn
        |> put_status(500)
        |> put_view(EmbersWeb.ErrorView)
        |> render("500.json", error: gettext("Internal error"))
    end
  end
end
