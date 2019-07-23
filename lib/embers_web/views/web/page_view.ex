defmodule EmbersWeb.PageView do
  use EmbersWeb, :view

  def render("auth.json", %{conn: conn} = assigns) do
    user = conn.assigns.current_user |> Embers.Repo.preload([:meta, :settings])
    settings = format_settings(user.settings)

    %{
      logged_in: !is_nil(user),
      csrf_token: Plug.CSRFProtection.get_csrf_token(),
      permissions: conn.assigns.permissions,
      user: render_one(user, EmbersWeb.UserView, "user.json"),
      user_token: handle_token(assigns),
      followed_tags: handle_tags(assigns),
      settings: settings
    }
  end

  defp handle_token(%{user_token: user_token}), do: user_token
  defp handle_token(_), do: nil

  defp handle_tags(%{tags: tags}) do
    render_many(tags, EmbersWeb.TagView, "tag.json")
  end

  defp handle_tags(_), do: []

  defp format_settings(settings) do
    Map.drop(settings, [
      :__schema__,
      :__meta__,
      :__struct__,
      :user,
      :user_id,
      :id,
      :inserted_at,
      :updated_at
    ])
  end
end
