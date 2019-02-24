defmodule EmbersWeb.MediaController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Media

  action_fallback(EmbersWeb.FallbackController)

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])

  def upload(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "file" => file
      }) do
    case Media.upload(file, user.id) do
      {:ok, media} ->
        conn
        |> render("media.json", %{media: media})

      {:error, :invalid_file} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", error: "Invalid image file")

      {:error, [{:http_error, _, %{body: error}}]} ->
        conn
        |> put_status(500)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", error: error)

      {:error, _error} ->
        IO.inspect(_error)

        conn
        |> put_status(500)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", error: "Internal error")
    end
  end
end
