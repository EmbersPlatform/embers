defmodule EmbersWeb.ActivitySubscriber do
  @moduledoc false

  use Embers.EventSubscriber, topics: ~w(new_activity)

  def handle_event(:new_activity, event) do
    %{post: post, recipients: recipients} = event.data

    post =
      post
      |> Embers.Posts.Post.fill_nsfw()

    locale = Application.get_env(:embers, EmbersWeb.Gettext) |> Keyword.get(:default_locale)
    EmbersWeb.Cldr.put_locale(locale)

    encoded_post =
      EmbersWeb.PostView.render("post.html",
        post: post,
        with_replies: true,
        conn: EmbersWeb.Endpoint
      )

    payload = %{post: encoded_post |> Phoenix.HTML.safe_to_string()}

    recipients
    |> Enum.reject(fn recipient -> recipient == post.user_id end)
    |> Enum.each(fn recipient ->
      # Broadcast the good news to the recipients via Channels
      EmbersWeb.Endpoint.broadcast!("feed:#{recipient}", "new_activity", payload)
    end)
  end
end
