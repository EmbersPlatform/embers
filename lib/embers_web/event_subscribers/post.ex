defmodule EmbersWeb.PostSubscriber do
  use Embers.EventSubscriber, topics: ~w(post_created)

  alias Embers.Helpers.IdHasher
  alias Embers.Feed

  import Ecto.Query

  require Logger

  def handle_event(:post_created, event) do
    post = event.data

    if(post.nesting_level == 0) do
      create_activity_and_push(post)
    end
  end

  defp create_activity_and_push(post) do
    followers = Feed.Subscriptions.list_followers_ids(post.user_id)
    blocked = Feed.Subscriptions.Blocks.list_users_ids_that_blocked(post.user_id)
    tags = Embers.Tags.list_post_tags_ids(post.id)

    tags_subscriptors =
      from(
        sub in Feed.Subscriptions.TagSubscription,
        where: sub.source_id in ^tags,
        select: sub.user_id
      )
      |> Embers.Repo.all()

    tags_blockers =
      from(
        block in Feed.Subscriptions.TagBlock,
        where: block.tag_id in ^tags,
        select: block.user_id
      )
      |> Embers.Repo.all()

    exceptions = Enum.concat(blocked, tags_blockers)

    recipients =
      Enum.concat(followers, tags_subscriptors)
      |> Enum.reject(fn el -> Enum.member?(exceptions, el) end)
      |> Enum.concat([post.user_id])
      |> Enum.uniq()

    # Create activity entries for the post
    Feed.push_acitivity(post, recipients)

    recipients
    |> Enum.reject(fn recipient -> recipient == post.user_id end)
    |> Enum.each(fn recipient ->
      # Broadcast the good news to the recipients via Channels
      hashed_id = IdHasher.encode(recipient)
      encoded_post = EmbersWeb.PostView.render("post.json", %{post: post})
      payload = %{post: encoded_post}

      EmbersWeb.Endpoint.broadcast!("feed:#{hashed_id}", "new_activity", payload)
    end)
  end
end
