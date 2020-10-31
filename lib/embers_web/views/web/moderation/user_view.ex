defmodule EmbersWeb.Web.Moderation.UserView do
  @moduledoc false

  use EmbersWeb, :view

  def render("users.json", %{page: page}) do
    page
    |> Embers.Paginator.map(&render(__MODULE__, "user.json", user: &1))
    |> Map.take([:entries, :next, :last_page])
  end

  def render("user.json", %{user: user}) do
    Map.take(user, [:id, :username, :canonical, :email])
    |> Map.put(:avatar, user.meta.avatar)
    |> Map.put(:cover, user.meta.cover)
    |> Map.put(:roles, Enum.map(user.roles, &Map.take(&1, [:id, :name])))
  end
end
