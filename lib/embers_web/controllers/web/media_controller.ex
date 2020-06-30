defmodule EmbersWeb.Web.MediaController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Media
  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(:user_check when action in [:upload])
  plug(CheckPermissions, [permission: "create_media"] when action in [:upload])

  def upload(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "file" => file
      }) do
    case Media.upload(file, user.id)do
      {:ok, media} ->
        conn
        |> render("media.json", %{media: media})

      {:error, :file_not_supported} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", error: "Invalid image file")

      {:error, _error} ->
        IO.puts(_error |> elem(0))
        conn
        |> put_status(500)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("500.json", error: "Internal error")
    end
  end
end
