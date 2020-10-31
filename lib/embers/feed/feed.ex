defmodule Embers.Feed do
  @moduledoc """
  Defines the behaviour all Feeds should implement
  """

  @callback get(options :: keyword) :: Embers.Paginator.Page.t()

  defmodule FeedActivity do
    @moduledoc false
    defstruct [:post, :sharers]

    def of(post) do
      %__MODULE__{post: post, sharers: []}
    end

    def of(post, sharer) do
      %__MODULE__{post: post, sharers: [sharer]}
    end
  end

  def group_shares(%Embers.Paginator.Page{entries: posts} = page) do
    put_in(page.entries, group_shares(posts))
  end

  def group_shares(posts) do
    is_share? = fn post ->
      !is_nil(post.related_to_id) and is_nil(post.body)
    end

    Enum.reduce(posts, [], fn post, acc ->
      case Enum.find_index(acc, fn x ->
             x.post.id == post.id || x.post.id == post.related_to_id
           end) do
        nil ->
          if is_share?.(post) do
            [FeedActivity.of(post.related_to, post.user) | acc]
          else
            [FeedActivity.of(post) | acc]
          end

        index ->
          if is_share?.(post) do
            List.update_at(acc, index, fn activity ->
              put_in(activity.sharers, [post.user | activity.sharers])
            end)
          else
            acc
          end
      end
    end)
    |> Enum.reverse()
  end
end
