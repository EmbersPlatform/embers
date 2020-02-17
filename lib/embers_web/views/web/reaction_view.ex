defmodule EmbersWeb.ReactionView do
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

  def render("stats.json", %{stats: stats}) do
    stats
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, x.name, x.count)
    end)
  end

  defp maybe_user(reaction) do
    if Ecto.assoc_loaded?(reaction.user) do
      render_one(reaction.user, EmbersWeb.UserView, "user.json")
    end
  end
end
