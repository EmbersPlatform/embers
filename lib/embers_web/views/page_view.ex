defmodule EmbersWeb.PageView do
  use EmbersWeb, :view

  def render("auth.json", %{conn: conn}) do
    user = conn.assigns.current_user |> Embers.Repo.preload(:meta)

    %{
      logged_in: !is_nil(user),
      csrf_token: Plug.CSRFProtection.get_csrf_token(),
      permissions: conn.assigns.permissions,
      user: render_one(user, EmbersWeb.UserView, "user.json")
    }
  end
end
