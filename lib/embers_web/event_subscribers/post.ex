defmodule EmbersWeb.ActivitySubscriber do
  @moduledoc false

  use Embers.EventSubscriber, topics: ~w(new_activity)

  alias Embers.Helpers.IdHasher

  def handle_event(:new_activity, event) do
    %{post: post, recipients: recipients} = event.data

    recipients
    |> Enum.reject(fn recipient -> recipient == post.user_id end)
    |> Enum.each(fn recipient ->
      # Broadcast the good news to the recipients via Channels
      hashed_id = IdHasher.encode(recipient)
      encoded_post = EmbersWeb.Web.PostView.render("post.json", %{post: post})
      payload = %{post: encoded_post}

      EmbersWeb.Endpoint.broadcast!("feed:#{hashed_id}", "new_activity", payload)
    end)
  end
end
