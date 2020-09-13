defmodule EmbersWeb.Web.UserFollowController do
  @moduledoc false

  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Subscriptions


  action_fallback(EmbersWeb.Web.FallbackController)
  plug(:user_check when action in [:create, :create_by_name, :delete])

  def create(conn, %{"id" => source_id} = _params) do
    user = conn.assigns.current_user
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
        |> render(EmbersWeb.Web.ErrorView, "422.json", changeset: changeset)
    end
  end

  def create_by_name(conn, %{"name" => name} = _params) do
    user = conn.assigns.current_user
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
        |> render(EmbersWeb.Web.ErrorView, "422.json", changeset: changeset)
    end
  end

  def destroy(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    Subscriptions.delete_user_subscription(user.id, id)

    conn |> put_status(:no_content) |> json(nil)
  end
end
