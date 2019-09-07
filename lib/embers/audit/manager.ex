defmodule Embers.Audit.Manager do
  use Embers.EventSubscriber, topics: ~w(post_disabled post_restored post_deleted user_banned)

  alias Embers.Audit

  def handle_event(:post_disabled, event) do
    %{post: post, actor: actor} = event.data

    Audit.create(%{
      user_id: actor,
      action: "disable_post",
      source: "#{post.id}"
    })
  end

  def handle_event(:post_restored, event) do
    %{post: post, actor: actor} = event.data

    Audit.create(%{
      user_id: actor,
      action: "restore_post",
      source: "#{post.id}"
    })
  end

  def handle_event(:post_deleted, event) do
    %{post: post, actor: actor} = event.data

    Audit.create(%{
      user_id: actor,
      action: "delete_post",
      source: "#{post.id}"
    })
  end

  def handle_event(:user_banned, event) do
    IO.puts("USER BANNED")
    %{ban: ban, actor: actor} = event.data

    Audit.create(%{
      user_id: actor,
      action: "ban_user",
      source: "#{ban.user_id}",
      details: [
        %{
          description: "Motivo: #{ban.reason}"
        }
      ]
    })
  end
end
