defmodule EmbersWeb.Api.BlockController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Blocks

  action_fallback(EmbersWeb.Web.FallbackController)
  plug(:user_check when action in [:update, :delete])

  def list(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    blocks =
      Blocks.list_blocks_paginated(user.id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "blocks.json", blocks)
  end

  def list_ids(conn, %{"id" => id} = params) do
    blocks_ids =
      Blocks.list_blocks_ids_paginated(id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "blocks_ids.json", blocks_ids)
  end

  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => source_id} = _params
      ) do
    do_create_block(conn, user.id, source_id)
  end

  def create_by_name(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"name" => name} = _params
      ) do
    source = Embers.Accounts.get_by_identifier(name)

    do_create_block(conn, user.id, source.id)
  end

  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
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
