defmodule EmbersWeb.Api.PageView do
  @moduledoc false
  use EmbersWeb, :view

  def render("auth.json", %{conn: conn} = assigns) do
    user = conn.assigns.current_user |> Embers.Repo.preload([:meta, :settings])
    settings = format_settings(user)

    %{
      logged_in: !is_nil(user),
      csrf_token: Plug.CSRFProtection.get_csrf_token(),
      user: render_one(user, EmbersWeb.Api.UserView, "user.json", as: :user),
      user_token: handle_token(assigns),
      followed_tags: handle_tags(assigns),
      settings: settings
    }
  end

  defp handle_token(%{user_token: user_token}), do: user_token
  defp handle_token(_), do: nil

  defp handle_tags(%{tags: tags}) do
    render_many(tags, EmbersWeb.Api.TagView, "tag.json", as: :tag)
  end

  defp handle_tags(_), do: []

  defp format_settings(%{settings: settings}) do
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

  defp format_settings(_) do
    %{}
  end
end
