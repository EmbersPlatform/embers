defmodule EmbersWeb.FriendController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Helpers.IdHasher
  alias Embers.Feed.Subscriptions

  action_fallback(EmbersWeb.FallbackController)
  plug(:id_check when action in [:update, :delete])

  def list(conn, %{"id" => id} = params) do
    id = IdHasher.decode(id)

    friends = Subscriptions.list_following_paginated(id, params)

    render(conn, "friends.json", friends)
  end

  def list_ids(conn, %{"id" => id} = params) do
    id = IdHasher.decode(id)

    friends_ids = Subscriptions.list_following_ids_paginated(id, params)

    render(conn, "friends_ids.json", friends_ids)
  end

  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => source_id} = _params
      ) do
    source_id = IdHasher.decode(source_id)

    sub_params = %{
      user_id: user.id,
      source_id: source_id
    }

    case Subscriptions.create_user_subscription(sub_params) do
      {:ok, _} ->
        conn
        |> put_status(:no_content)
        |> json(nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end

  def create_by_name(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"name" => name} = _params
      ) do
    source = Embers.Accounts.get_by_identifier(name)

    sub_params = %{
      user_id: user.id,
      source_id: source.id
    }

    case Subscriptions.create_user_subscription(sub_params) do
      {:ok, _} ->
        conn
        |> put_status(:no_content)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end

  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)

    Subscriptions.delete_user_subscription(user.id, id)

    conn |> put_status(:no_content) |> json(nil)
  end
end