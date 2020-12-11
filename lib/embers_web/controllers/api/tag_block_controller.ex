defmodule EmbersWeb.Api.TagBlockController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Subscriptions.Tags

  action_fallback(EmbersWeb.Web.FallbackController)
  plug(:user_check when action in [:update, :delete])

  def list(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    blocks =
      Tags.list_blocked_tags_paginated(user.id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "tags_paginated.json", blocks)
  end

  def list_ids(conn, %{"id" => id} = params) do
    blocks_ids =
      Tags.list_blocked_tags_ids_paginated(id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "tags_ids.json", blocks_ids)
  end

  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => source_id} = _params
      ) do
    do_create_block(conn, user.id, source_id)
  end

  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"name" => name} = _params
      ) do
    do_create_block(conn, user.id, name)
  end

  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    Tags.delete_block(user.id, id)

    conn |> json(nil)
  end

  defp do_create_block(conn, user_id, tag) do
    case Tags.create_block(user_id, tag) do
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
