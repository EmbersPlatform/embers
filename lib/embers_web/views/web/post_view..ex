defmodule EmbersWeb.Web.PostView do
  @moduledoc false

  use EmbersWeb, :view

  alias Embers.Posts.Post

  # alias Embers.Helpers.IdHasher
  alias EmbersWeb.Web.UserView

  def render("show.json", %{post: post}) do
    render("post.json", %{post: post})
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      body: post.body,
      created_at: post.inserted_at,
      deleted: !is_nil(post.deleted_at),
      stats: %{
        replies: post.replies_count,
        shares: post.shares_count
      },
      nesting_level: post.nesting_level,
      nsfw: post.nsfw,
      faved: post.faved,
      user: render_one(post.user, UserView, "user.json")
    }
  end

  def build_reactions(post, viewer \\ nil)
  def build_reactions(post, %{assigns: %{current_user: user}}) when not is_nil(user) do
    build_reactions(post, user.id)
  end
  def build_reactions(post, %{}) do
    build_reactions(post, nil)
  end
  def build_reactions(post, viewer_id) do
    reactions = get_reactions(post, viewer_id)

    for reaction <- reactions do
      reaction_image = static_path(Endpoint, "/svg/reactions/#{reaction.name}.svg")

      ~E"""
      <button
        class="reaction"
        data-name="<%= reaction.name %>"
        data-total="<%= reaction.total %>"
        data-action="click->reactable#onToggleReaction"
        <%= if reaction.reacted, do: "reacted" %>
      >
        <img src="<%= reaction_image %>">
        <span class="reaction-total"><%= reaction.total %></span>
      </button>
      """
    end
  end

  defp get_reactions(post, viewer_id) do
    if Ecto.assoc_loaded?(post.reactions) do
      my_reactions =
        unless is_nil(viewer_id) do
          post.reactions
          |> Enum.filter(fn r -> r.user_id == viewer_id end)
          |> Enum.map(fn r -> r.name end)
        end || []

      reactions_map = format_reactions(post.reactions, my_reactions)

      reactions_map
    end || []
  end

  defp format_reactions(reactions, my_reactions) do
    reactions
    |> Enum.group_by(&Map.get(&1, :name))
    |> Enum.map(fn {k, v} ->
      %{
        total: Enum.count(v),
        name: k,
        reacted: Enum.member?(my_reactions, k)
      }
    end)
  end

  def get_replies(post) do
    if Ecto.assoc_loaded?(post.replies) do
      post.replies
    end || []
  end

  def has_related?(post) do
    match?(%Post{}, post.related_to)
  end
end
