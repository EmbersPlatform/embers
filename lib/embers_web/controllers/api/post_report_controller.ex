defmodule EmbersWeb.Api.PostReportController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Posts
  alias Embers.Reports
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "create_report"] when action in [:create])

  def create(%{assigns: %{current_user: user}} = conn, %{"post_id" => id} = params) do
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
