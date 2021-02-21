defmodule EmbersWeb.ActivitySubscriber do
  @moduledoc false

  use GenServer

  def start_link(defaults) when is_list(defaults) do
    GenServer.start_link(__MODULE__, defaults)
  end

  def init(init_args) do
    require Logger

    :ok = Embers.Feed.Timeline.subscribe()
    :ok = Embers.Feed.ActivitySubscriber.subscribe()

    Logger.info("#{inspect(__MODULE__)} initialized")

    {:ok, init_args}
  end

  def handle_info({Embers.Feed.ActivitySubscriber, :new_activity, activity}, state) do
    %{post: post, recipients: recipients} = activity

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

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
