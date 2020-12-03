defmodule EmbersWeb.Api.TagController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Accounts
  alias Embers.Subscriptions.Tags, as: Subscriptions

  alias Embers.Tags

  action_fallback(EmbersWeb.Web.FallbackController)
  plug(:user_check when action in ~w(list list_ids create create_by_name destroy)a)

  def show_tag(conn, %{"name" => name}) do
    case Tags.get_by_name(name) do
      nil ->
        conn |> put_status(:not_found) |> json(nil)

      tag ->
        render(conn, "tag.json", tag: tag)
    end
  end

  def show_tag_posts(conn, %{"name" => name} = params) do
    results = Tags.list_tag_posts(name, before: params["before"], limit: params["limit"])
    render(conn, EmbersWeb.Web.FeedView, "timeline.json", results)
  end

  @doc false
  def list(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    tags =
      Subscriptions.list_subscribed_tags_paginated(user.id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "tags_paginated.json", tags)
  end

  @doc false
  def list_ids(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    tags_ids =
      Subscriptions.list_subscribed_tags_ids_paginated(user.id,
        after: params["after"],
        before: params["before"],
        limit: params["limit"]
      )

    render(conn, "tags_ids.json", tags_ids)
  end

  @doc false
  def create(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => source_id} = params
      ) do
    level = Map.get(params, "level", 1)

    sub_params = %{
      user_id: user.id,
      source_id: source_id,
      level: level
    }

    do_create_subscription(conn, sub_params)
  end

  @doc false
  def create_by_name(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"name" => name} = params
      ) do
    source = Accounts.get_by_identifier(name)
    level = Map.get(params, "level", 1)

    sub_params = %{
      user_id: user.id,
      source_id: source.id,
      level: level
    }

    do_create_subscription(conn, sub_params)
  end

  @doc false
  def destroy(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    Subscriptions.delete_subscription(user.id, id)

    conn |> put_status(200) |> json(nil)
  end

  def create_block(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => tag_id} = _params
      ) do
    block_params = %{
      user_id: user.id,
      tag_id: tag_id
    }

    do_create_block(conn, block_params)
  end

  def popular(conn, _params) do
    popular = Tags.get_popular_tags(limit: 5)

    conn
    |> render("popular.json", popular: popular)
  end

  def hot(conn, _params) do
    hot = Tags.get_hot_tags(limit: 5)

    conn
    |> render("hot.json", hot: hot)
  end

  defp do_create_subscription(conn, sub_params) do
    case Subscriptions.create_or_update_subscription(sub_params) do
      {:ok, sub} ->
        sub = sub |> Embers.Repo.preload([:source])

        conn
        |> render("tag.json", %{tag: sub.source})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.Web.ErrorView, "422.json", changeset: changeset)
    end
  end

  defp do_create_block(conn, %{user_id: user_id, tag_id: tag_id}) do
    case Subscriptions.create_block(user_id, tag_id) do
      {:ok, _} ->
        conn
        |> json(nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmbersWeb.Web.ErrorView, "422.json", changeset: changeset)
    end
  end
end
