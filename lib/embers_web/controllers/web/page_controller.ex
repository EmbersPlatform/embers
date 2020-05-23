defmodule EmbersWeb.Web.PageController do
  @moduledoc false

  use EmbersWeb, :controller

  alias Embers.Helpers.IdHasher
  alias Embers.Feed.Timeline

  def index(%Plug.Conn{assigns: %{current_user: nil}} = conn, _params) do
    render(conn, "landing.html")
  end

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, params) do
    timeline =
      Timeline.get(
        user_id: current_user.id,
        with_replies: 2,
        after: IdHasher.decode(params["after"]),
        before: IdHasher.decode(params["before"]),
        limit: params["limit"]
      )

    render(conn, "index.html", page_title: gettext("Home"), timeline: timeline)
  end

  def rules(conn, _params) do
    rules = Embers.Settings.get!("rules")
    send_resp(conn, 200, rules.string_value)
  end

  def faq(conn, _params) do
    faq = Embers.Settings.get!("faq")
    send_resp(conn, 200, faq.string_value)
  end

  def acknowledgments(conn, _params) do
    acknowledgments = Embers.Settings.get!("acknowledgments")
    send_resp(conn, 200, acknowledgments.string_value)
  end
end
