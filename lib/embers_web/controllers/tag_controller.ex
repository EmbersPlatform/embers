defmodule EmbersWeb.TagController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Helpers.IdHasher

  alias Embers.Feed.Subscriptions.Tags, as: Subscriptions

  action_fallback(EmbersWeb.FallbackController)
  plug(:user_check when action in ~w(list list_ids create create_by_name destroy)a)

  @doc false
  def list(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    tags = Subscriptions.list_subscribed_tags_paginated(user.id, params)

    render(conn, "tags_paginated.json", tags)
  end

  @doc false
  def list_ids(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    tags_ids = Subscriptions.list_subscribed_tags_ids_paginated(user.id, params)

    render(conn, "tags_ids.json", tags_ids)
  end

  @doc false
  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => source_id} = _params
      ) do
    source_id = IdHasher.decode(source_id)

    sub_params = %{
      user_id: user.id,
      source_id: source_id
    }

    do_create_subscription(conn, sub_params)
  end

  @doc false
  def create_by_name(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"name" => name} = _params
      ) do
    source = Embers.Accounts.get_by_identifier(name)

    sub_params = %{
      user_id: user.id,
      source_id: source.id
    }

    do_create_subscription(conn, sub_params)
  end

  @doc false
  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    id = IdHasher.decode(id)

    Subscriptions.delete_subscription(user.id, id)

    conn |> put_status(:no_content) |> json(nil)
  end

  def create_block(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => tag_id} = _params
      ) do
    tag_id = IdHasher.decode(tag_id)

    block_params = %{
      user_id: user.id,
      tag_id: tag_id
    }

    do_create_block(conn, block_params)
  end

  defp do_create_subscription(conn, sub_params) do
    case Subscriptions.create_subscription(sub_params) do
      {:ok, sub} ->
        sub = sub |> Embers.Repo.preload([:source])

        conn
        |> render("tag.json", %{tag: sub.source})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.ErrorView, "422.json", changeset: changeset)
    end
  end

  defp do_create_block(conn, block_params) do
    case Subscriptions.create_block(block_params) do
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
end
