defmodule EmbersWeb.LayoutView do
  @moduledoc false

  use EmbersWeb, :view

  alias Embers.Helpers.IdHasher

  def render_layout(layout, assigns, do: content) do
    render(layout, Map.put(assigns, :inner_layout, content))
  end

  def get_context_data(conn) do
    Map.new()
    |> Map.put(:csrf_token, Phoenix.Controller.get_csrf_token)
    |> maybe_add_user_data(conn)
    |> Jason.encode!()
  end

  defp maybe_add_user_data(data, %{assigns: %{current_user: nil}}), do: data
  defp maybe_add_user_data(data, conn) do
    user = conn.assigns.current_user
    data
    |> Map.put(:user, %{
      id: IdHasher.encode(user.id),
      username: user.username,
      canonical: user.canonical,
      avatar: user.meta.avatar,
      cover: user.meta.cover
    })
    |> Map.put(:permissions, user.permissions)
    |> Map.put(:ws_token, conn.assigns.user_token)
  end

  @doc """
  Renders the sidebar if there's an authenticated user
  """
  def sidebar(assigns) do
    sidebar(nil, assigns)
  end

  def sidebar(assigns, do: content) do
    sidebar(content, assigns)
  end

  def sidebar(content, assigns) do
    conn = assigns.conn
    user = conn.assigns.current_user

    if is_nil(user) do
      ""
    else
      content = if is_nil(content), do: sidebar_default_content(), else: content

      ~E"""
      <nav id="sidebar" is="embers-sidebar">
        <%= content %>
        <footer>
          <pop-up class="nav-user-menu" data-controller="user-menu">
            <img src="<%= user.meta.avatar.small %>" class="user-avatar" pop-up-trigger/>
            <ul pop-up-content>
              <li>
                <%= link("My profile",
                    to: decoded_path(:user_path, conn, :show, user.canonical),
                    class: "button-link"
                  )
                %>
              </li>
              <li>
                <button class="plain-button" data-action="user-menu#log_out">Log out</button>
              </li>
            </ul>
          </pop-up>
        </footer>
      </nav>
      """
    end
  end

  defp sidebar_default_content() do
    render("_default_sidebar.html")
  end
end
