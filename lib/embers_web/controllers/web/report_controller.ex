defmodule EmbersWeb.Web.ReportController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Posts
  alias Embers.Reports

  alias EmbersWeb.Plugs.CheckPermissions

  action_fallback(EmbersWeb.Web.FallbackController)

  plug(CheckPermissions, [permission: "create_report"] when action in [:create])

  def create_post_report(conn, %{"post_id" => id} = params) do
    user = conn.assigns.current_user
    reportable = Posts.get_post!(id)

    attrs = [comments: params["comments"]]

    with {:ok, _report} <- Reports.report(reportable, user, attrs) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.Web.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end
end
