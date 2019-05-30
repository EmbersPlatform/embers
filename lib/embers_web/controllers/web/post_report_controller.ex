defmodule EmbersWeb.PostReportController do
  use EmbersWeb, :controller

  import Embers.Helpers.IdHasher

  alias Embers.Reports
  alias EmbersWeb.Plugs.CheckPermissions

  plug(CheckPermissions, [permission: "create_report"] when action in [:create])

  def create(%{assigns: %{current_user: user}} = conn, %{"post_id" => id} = params) do
    reportable = Embers.Feed.get_post!(decode(id))

    attrs = [comments: params["comments"]]

    with {:ok, _report} <- Reports.report(reportable, user, attrs) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(EmbersWeb.ErrorView)
        |> render("422.json", %{error: reason})
    end
  end
end
