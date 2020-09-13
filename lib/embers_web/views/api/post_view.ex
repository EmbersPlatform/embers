defmodule EmbersWeb.Api.PostView do
  @moduledoc false
  use EmbersWeb, :view


  alias EmbersWeb.{Api.LinkView, Api.MediaView, Api.PostView, Api.UserView}

  def render("show.json", %{post: post, current_user: current_user})
      when not is_nil(current_user) do
    render(PostView, "post.json", %{post: post, current_user: current_user})
  end

  def render("show.json", %{post: post}) do
    render(PostView, "post.json", %{post: post})
  end

  def render("post.json", %{post: post}) when is_nil(post) do
    nil
  end

  def render("post.json", %{post: post} = assigns) do
    view =
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
        faved: post.faved
      }
      |> handle_tags(post)
      |> put_in_reply_to(post)
      |> put_user(post)
      |> handle_media(post)
      |> handle_links(post)
      |> handle_reactions(post, assigns)

    if Map.get(assigns, :with_related, true) do
      view
      |> handle_related(post, assigns)
    end || view
  end

  def render("show_replies.json", %{entries: posts} = metadata) do
    %{
      items:
        Enum.map(posts, fn post ->
          render(
            __MODULE__,
            "show.json",
            %{post: post, current_user: metadata.current_user}
          )
        end),
      next: metadata.next,
      last_page: metadata.last_page
    }
  end

  defp handle_tags(view, post) do
    if Ecto.assoc_loaded?(post.tags) do
      Map.put(
        view,
        "tags",
        render_many(post.tags, EmbersWeb.Api.TagView, "tag.json", as: :tag)
      )
    end || view
  end

  defp put_in_reply_to(view, post) do
    if not is_nil(post.parent_id) do
      Map.put(view, "in_reply_to", post.parent_id)
    end || view
  end

  defp put_user(view, post) do
    if Ecto.assoc_loaded?(post.user) do
      Map.put(view, "user", render_one(post.user, UserView, "user.json", as: :user))
    end || view
  end

  defp handle_media(
         view,
         %{old_attachment: %{"url" => url, "meta" => meta, "type" => type}} = _post
       )
       when not is_nil(url) do
    meta =
      case meta do
        nil -> nil
        %{"image" => image} -> Map.put(meta, "preview_url", image)
        _ -> Map.put(meta, "preview_url", url)
      end

    Map.put(view, "media", [
      %{
        "type" => type,
        "url" => url,
        "metadata" => meta,
        "legacy" => true
      }
    ])
  end

  defp handle_media(view, post) do
    if Ecto.assoc_loaded?(post.media) do
      ordered_medias = post.media |> Enum.sort_by(& &1.inserted_at)

      Map.put(
        view,
        "media",
        render_many(ordered_medias, MediaView, "media.json", as: :media)
      )
    end || view
  end

  defp handle_links(view, post) do
    if Ecto.assoc_loaded?(post.links) do
      Map.put(view, "links", render_many(post.links, LinkView, "link.json", as: :link))
    end || view
  end

  defp handle_related(view, post, assigns) do
    if Ecto.assoc_loaded?(post.related_to) && not is_nil(post.related_to) do
      Map.put(
        view,
        "related_to",
        render(__MODULE__, "post.json", %{post: post.related_to, with_related: false})
        |> handle_reactions(post.related_to, assigns)
      )
    end || view
  end

  defp handle_reactions(view, post, assigns) do
    if Ecto.assoc_loaded?(post.reactions) do
      my_reactions =
        if Map.has_key?(assigns, :current_user) do
          post.reactions
          |> Enum.filter(fn r -> r.user_id == assigns.current_user.id end)
          |> Enum.map(fn r -> r.name end)
        end || []

      reactions_map = format_reactions(post.reactions, my_reactions)

      Map.put(view, "reactions", reactions_map)
    end || view
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
end
