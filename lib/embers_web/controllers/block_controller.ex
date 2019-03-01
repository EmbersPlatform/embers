defmodule EmbersWeb.BlockController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Helpers.IdHasher
  alias Embers.Feed.Subscriptions.Blocks

  action_fallback(EmbersWeb.FallbackController)
  plug(:user_check when action in [:update, :delete])

  def list(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    blocks = Blocks.list_blocks_paginated(user.id, params)

    render(conn, "blocks.json", blocks)
  end

  def list_ids(conn, %{"id" => id} = params) do
    id = IdHasher.decode(id)

    blocks_ids = Blocks.list_blocks_ids_paginated(id, params)

    render(conn, "blocks_ids.json", blocks_ids)
  end

  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => source_id} = _params
      ) do
    source_id = IdHasher.decode(source_id)

    block_params = %{
      user_id: user.id,
      source_id: source_id
    }

    do_create_block(conn, block_params)
  end

  def create_by_name(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"name" => name} = _params
      ) do
    source = Embers.Accounts.get_by_identifier(name)

    block_params = %{
      user_id: user.id,
      source_id: source.id
    }

    do_create_block(conn, block_params)
  end

  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)

    Blocks.delete_user_block(user.id, id)

    conn |> put_status(:no_content) |> json(nil)
  end

  defp do_create_block(conn, block_params) do
    case Blocks.create_user_block(block_params["user_id"], block_params["source_id"]) do
      {:ok, _} ->
        conn
        |> put_status(:no_content)
        |> json(nil)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end
end
