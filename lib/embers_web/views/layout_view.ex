defmodule EmbersWeb.LayoutView do
  @moduledoc false

  use EmbersWeb, :view

  def render_layout(layout, assigns, do: content) do
    render(layout, Map.put(assigns, :inner_layout, content))
  end

  def sidebar(assigns) do
    sidebar(nil, assigns)
  end

  def sidebar(assigns, do: content) do
    sidebar(content, assigns)
  end

  def sidebar(content, assigns) do
    conn = assigns.conn
    user = conn.assigns.current_user
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

  defp sidebar_default_content() do
    render("_default_sidebar.html")
  end
end
