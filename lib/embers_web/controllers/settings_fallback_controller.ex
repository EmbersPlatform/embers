defmodule EmbersWeb.SettingsFallbackController do
  @moduledoc false

  use EmbersWeb, :controller

  def call(conn, {:error, :invalid_format}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Invalid file format"})
  end
end
