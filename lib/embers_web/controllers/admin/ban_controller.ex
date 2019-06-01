defmodule EmbersWeb.Admin.BanController do
  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Moderation

  plug(:put_layout, "dashboard.html")

  def index(conn, params) do
    page =
      Moderation.list_all_bans(
        after: IdHasher.decode(params["after"]),
        limit: params["limit"],
        name: params["name"]
      )

    page = %{
      page
      | entries:
          page.entries
          |> Enum.map(fn ban ->
            ban = ban |> Embers.Repo.preload(:user)

            expires =
              case ban.expires_at do
                nil -> "Indefinida"
                _ -> Timex.format!(ban.expires_at, "{D}/{0M}/{YYYY}")
              end

            %{ban | expires_at: expires}
          end)
    }

    render(conn, "list.html",
      bans: page.entries,
      next: page.next,
      last_page: page.last_page
    )
  end
end
