defmodule EmbersWeb.Moderation.RoleView do
  @moduledoc false

  use EmbersWeb, :view

  def render("role.json", %{role: role}) do
    %{id: role.id, name: role.name, permissions: role.permissions}
  end
end
