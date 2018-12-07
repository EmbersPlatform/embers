defmodule Embers.Feed.Subscriptions.Blocks do
  import Ecto.Query

  alias Embers.Feed.Subscriptions.{UserBlock}
  alias Embers.Repo
  alias Embers.Paginator

  def create_user_block(attrs \\ %{}) do
    block = UserBlock.changeset(%UserBlock{}, attrs)
    Repo.insert(block)
  end

  def delete_user_block(user_id, source_id) do
    sub = Repo.get_by(UserBlock, %{user_id: user_id, source_id: source_id})

    if(not is_nil(sub)) do
      Repo.delete(sub)
    end
  end

  def list_users_blocked_ids_by(user_id) do
    from(
      block in UserBlock,
      where: block.user_id == ^user_id,
      select: block.source_id
    )
    |> Repo.all()
  end

  def list_users_ids_that_blocked(user_id) do
    from(
      block in UserBlock,
      where: block.source_id == ^user_id,
      select: block.user_id
    )
    |> Repo.all()
  end

  def list_blocks_ids(user_id) do
    UserBlock
    |> where([block], block.source_id == ^user_id)
    |> select([block], block.user_id)
    |> Repo.all()
  end

  def list_blocks_paginated(user_id, opts \\ %{}) do
    UserBlock
    |> where([block], block.user_id == ^user_id)
    |> join(:left, [block], user in assoc(block, :source))
    |> join(:left, [block, user], meta in assoc(user, :meta))
    |> preload([block, user, meta], user: {user, meta: meta})
    |> Paginator.paginate(opts)
  end

  def list_blocks_ids_paginated(user_id, opts \\ %{}) do
    UserBlock
    |> where([block], block.user_id == ^user_id)
    |> select([block], block.source_id)
    |> Paginator.paginate(opts)
  end
end
