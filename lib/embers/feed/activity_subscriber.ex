defmodule Embers.Feed.ActivitySubscriber do
  use Embers.EventSubscriber, topics: ~w(post_created)

  alias Embers.Blocks
  alias Embers.Feed.Timeline
  alias Embers.Subscriptions

  import Ecto.Query

  require Logger

  def handle_event(:post_created, event) do
    post = event.data

    if post.nesting_level == 0 do
      create_activity_and_push(post)
    end
  end

  defp create_activity_and_push(post) do
    followers = Subscriptions.list_followers_ids(post.user_id)
    blocked = Blocks.list_users_ids_that_blocked(post.user_id)
    tag_names = Embers.Tags.list_post_tag_names(post.id) |> Enum.map(&String.upcase/1)

    tags =
      from(
        tag in Embers.Tags.Tag,
        where: fragment("upper(?)", tag.name) in ^tag_names,
        select: tag.id
      )
      |> Embers.Repo.all()

    tags_subscriptors =
      from(
        sub in Subscriptions.TagSubscription,
        where: sub.level == 1,
        where: sub.source_id in ^tags,
        select: sub.user_id
      )
      |> Embers.Repo.all()

    tags_blockers =
      from(
        block in Blocks.TagBlock,
        where: block.tag_id in ^tags,
        or_where: block.user_id in ^tags_subscriptors,
        select: block.user_id
      )
      |> Embers.Repo.all()

    followers =
      if post.nsfw do
        # get the followers that don't want to hide nsfw posts
        from(
          setting in Embers.Profile.Settings.Setting,
          where: setting.user_id in ^followers,
          where: setting.content_nsfw != "hide",
          select: setting.user_id
        )
        |> Embers.Repo.all()
      else
        followers
      end

    exceptions = Enum.concat(blocked, tags_blockers)

    recipients =
      Enum.concat(followers, tags_subscriptors)
      |> Enum.reject(fn el -> Enum.member?(exceptions, el) end)
      |> Enum.concat([post.user_id])
      |> Enum.uniq()

    # Create activity entries for the post
    Timeline.push_activity(post, recipients)

    Embers.Event.emit(:new_activity, %{post: post, recipients: recipients})
  end
end
