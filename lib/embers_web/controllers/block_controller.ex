defmodule EmbersWeb.BlockController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Blocks

  action_fallback(EmbersWeb.FallbackController)

  plug(:user_check)

  def index(conn, params) do
    user = conn.assigns.current_user

    blocks =
      Blocks.list_blocks_paginated(user.id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "index.html", blocks)
  end

  def create(conn, %{"id" => source_id}) do
    do_create_block(conn, conn.assigns.current_user.id, source_id)
  end

  def create(conn, %{"name" => name}) do
    source = Embers.Accounts.get_user_by_username(name)

    do_create_block(conn, conn.assigns.current_user.id, source.id)
  end

  def destroy(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    Blocks.delete_user_block(user.id, id)

    conn |> json(nil)
  end

  defp do_create_block(conn, user_id, source_id) do
    case Blocks.create_user_block(user_id, source_id) do
      {:ok, _} ->
        conn
        |> json(nil)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end
end
