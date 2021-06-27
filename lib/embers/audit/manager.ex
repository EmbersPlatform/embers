defmodule Embers.Audit.Manager do
  use GenServer

  alias Embers.Audit

  @type state :: term

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(init_arg) do
    Embers.Posts.subscribe()
    Embers.Moderation.subscribe()
    {:ok, init_arg}
  end

  @spec handle_info(
          event ::
            {Embers.Posts, Embers.Posts.event() | Embers.Moderation.event(),
             Posts.post_and_actor()},
          state
        ) ::
          {:noreply, state}
  def handle_info({Embers.Posts, {:post, :disabled}, %{post: post, actor: actor}}, state) do
    Audit.create(%{
      user_id: "#{actor}",
      action: "disable_post",
      source: "#{post.id}",
      details: [%{action: "in_post"}]
    })

    {:noreply, state}
  end

  def handle_info({Embers.Posts, {:post, :restored}, %{post: post, actor: actor}}, state) do
    Audit.create(%{
      user_id: "#{actor.id}",
      action: "restore_post",
      source: "#{post.id}",
      details: %{
        action: "in_post"
      }
    })

    {:noreply, state}
  end

  def handle_info({Embers.Posts, {:post, :deleted}, %{post: post, actor: actor}}, state) do
    Audit.create(%{
      user_id: "#{actor}",
      action: "delete_post",
      source: "#{post.id}",
      details: %{
        action: "in_post"
      }
    })

    {:noreply, state}
  end

  def handle_info({Embers.Moderation, {:user, :banned}, %{ban: ban, actor: actor}}, state) do
    ban = Embers.Repo.preload(ban, :user)

    Audit.create(%{
      user_id: "#{actor}",
      action: "ban_user",
      source: "#{ban.user.id}",
      details: [
        %{
          action: "in_user",
          description: ban.user.username
        },
        %{
          description: "Motivo: #{ban.reason}"
        }
      ]
    })

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
