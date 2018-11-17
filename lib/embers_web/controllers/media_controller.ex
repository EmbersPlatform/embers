defmodule EmbersWeb.MediaController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Media

  action_fallback(EmbersWeb.FallbackController)

  plug(:user_check when action in [:new, :create, :edit, :update, :delete])

  def upload(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "image" => file
      }) do
    case Media.upload(file, user.id) do
      {:ok, media} ->
        conn
        |> render("media.json", %{media: media})

      {:error, :invalid_file} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", error: "Invalid image file")

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", error: error)
    end
  end
end
