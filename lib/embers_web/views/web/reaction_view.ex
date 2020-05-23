defmodule EmbersWeb.Web.ReactionView do
  @moduledoc false

  use EmbersWeb, :view

  def render("reactions.json", %{entries: reactions} = metadata) do
    %{
      entries: render_many(reactions, __MODULE__, "reaction.json"),
      last_page: metadata.last_page,
      next: metadata.next
    }
  end

  def render("reaction.json", %{reaction: reaction}) do
    %{
      name: reaction.name,
      user: maybe_user(reaction)
    }
  end

  def render("overview.json", %{reactions: reactions}) do
    reactions
  end

  defp maybe_user(reaction) do
    if Ecto.assoc_loaded?(reaction.user) do
      render_one(reaction.user, EmbersWeb.Api.UserView, "user.json")
    end
  end
end
