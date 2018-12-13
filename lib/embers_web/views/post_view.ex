defmodule EmbersWeb.PostView do
  use EmbersWeb, :view

  alias EmbersWeb.{PostView, UserView, MediaView}
  alias Embers.Helpers.IdHasher

  def render("show.json", %{post: post, current_user: current_user})
      when not is_nil(current_user) do
    render(PostView, "post.json", %{post: post, current_user: current_user})
  end

  def render("show.json", %{post: post}) do
    render(PostView, "post.json", %{post: post})
  end

  def render("post.json", %{post: post} = assigns) do
    view = %{
      id: IdHasher.encode(post.id),
      body: post.body,
      created_at: post.inserted_at,
      stats: %{
        replies: post.replies_count,
        shares: post.shares_count
      },
      nesting_level: post.nesting_level
    }

    view = handle_tags(post, view)

    view =
      if not is_nil(post.parent_id) do
        Map.put(view, "in_reply_to", IdHasher.encode(post.parent_id))
      else
        view
      end

    view =
      if Ecto.assoc_loaded?(post.user) do
        Map.put(view, "user", render_one(post.user, UserView, "user.json"))
      else
        view
      end

    view =
      if(Ecto.assoc_loaded?(post.media)) do
        Map.put(view, "media", render_many(post.media, MediaView, "media.json", as: :media))
      else
        view
      end

    view =
      if(Ecto.assoc_loaded?(post.reactions)) do
        my_reactions =
          case Map.has_key?(assigns, :current_user) do
            true ->
              post.reactions
              |> Enum.filter(fn r -> r.user_id == assigns.current_user.id end)
              |> Enum.map(fn r -> r.name end)

            _ ->
              []
          end

        reactions_map =
          post.reactions
          |> Enum.reduce(%{}, fn %{name: name}, acc ->
            case acc do
              %{^name => map} ->
                Map.put(acc, name, %{
                  name: name,
                  total: (map.total || 0) + 1,
                  reacted: Enum.member?(my_reactions, name)
                })

              _ ->
                Map.put(acc, name, %{
                  name: name,
                  total: (acc[name] || 0) + 1,
                  reacted: Enum.member?(my_reactions, name)
                })
            end
          end)

        Map.put(view, "reactions", reactions_map)
      else
        view
      end

    view
  end

  def render("show_replies.json", %{entries: replies} = metadata) do
    %{
      items: render_many(replies, __MODULE__, "post.json", as: :post),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  defp handle_tags(post, view) do
    if(Ecto.assoc_loaded?(post.tags)) do
      Map.put(view, "tags", Enum.map(post.tags, fn tag -> tag.name end))
    else
      view
    end
  end
end
