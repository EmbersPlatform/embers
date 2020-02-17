defmodule Embers.Blocks do
  @moduledoc """
  Constains functions to handle Blocks.
  When something is blocked by an user, the user MUST NOT receive any content
  related to it. For example, if I block a user, I should stop seeing posts
  made by it.

  In the cases where a user has blocked another user and at the same time is
  following it, the block should have priority.
  """

  import Ecto.Query

  alias Embers.Blocks.UserBlock
  alias Embers.Paginator
  alias Embers.Repo

  @doc """
  Creates a user block

  ## Examples
      iex> create_user_block(1,2)
      {:ok, %UserBlock{}}

      iex> create_user_block(3, 4)
      {:error, %Ecto.Changeset()}
  """
  @spec create_user_block(integer(), integer()) ::
          {:ok, Embers.Subscriptions.UserBlock.t()} | {:error, Ecto.Changeset.t()}
  def create_user_block(user_id, source_id) do
    block = UserBlock.changeset(%UserBlock{}, %{user_id: user_id, source_id: source_id})
    Repo.insert(block)
  end

  @doc """
  Deletes a user block, returns the deleted block or `nil` if not found

  ## Examples
      iex> delete_user_block(1, 2)
      %UserBlock{}

      iex> delete_user_block(3, 4)
      nil
  """
  @spec delete_user_block(integer(), integer()) :: nil
  def delete_user_block(user_id, source_id) do
    sub = Repo.get_by(UserBlock, %{user_id: user_id, source_id: source_id})

    unless is_nil(sub) do
      Repo.delete(sub)
    end
  end

  @doc """
  Returns the list of ids of the users that were blocked by `user_id`
  """
  @spec list_users_blocked_ids_by(integer()) :: [
          Embers.Subscriptions.UserBlock.t()
        ]
  def list_users_blocked_ids_by(user_id) do
    Repo.all(
      from(
        block in UserBlock,
        where: block.user_id == ^user_id,
        select: block.source_id
      )
    )
  end

  @doc """
  Returns the list of ids of the users that blocked `user_id`
  """
  @spec list_users_ids_that_blocked(integer()) :: [any()]
  def list_users_ids_that_blocked(user_id) do
    Repo.all(
      from(
        block in UserBlock,
        where: block.source_id == ^user_id,
        select: block.user_id
      )
    )
  end

  @deprecated "Use list_users_ids_that_blocked/1 instead"
  @spec list_blocks_ids(integer()) :: [any()]
  def list_blocks_ids(user_id) do
    UserBlock
    |> where([block], block.source_id == ^user_id)
    |> select([block], block.user_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of blocked users, paginated with `Paginator`
  """
  @spec list_blocks_paginated(integer(), list()) :: Embers.Paginator.Page.t()
  def list_blocks_paginated(user_id, opts \\ []) do
    # TODO convert to `from` query
    UserBlock
    |> where([block], block.user_id == ^user_id)
    |> join(:left, [block], user in assoc(block, :source))
    |> join(:left, [block, user], meta in assoc(user, :meta))
    |> preload([block, user, meta], user: {user, meta: meta})
    |> Paginator.paginate(opts)
  end

  @doc """
   Same as `list_users_blocked_ids_by/1` but paginated with `Paginator`
  """
  @spec list_blocks_ids_paginated(integer(), list()) :: Embers.Paginator.Page.t()
  def list_blocks_ids_paginated(user_id, opts \\ []) do
    UserBlock
    |> where([block], block.user_id == ^user_id)
    |> select([block], block.source_id)
    |> Paginator.paginate(opts)
  end

  @doc """
  Checks if the `from` user was blocked by the `recipient` user
  """
  @spec blocked?(integer(), integer()) :: boolean()
  def blocked?(from, recipient) do
    Repo.exists?(
      from(
        block in UserBlock,
        where: block.user_id == ^recipient and block.source_id == ^from
      )
    )
  end
end
