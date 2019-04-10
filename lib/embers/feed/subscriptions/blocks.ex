defmodule Embers.Feed.Subscriptions.Blocks do
  @moduledoc """
  Los bloqueos son lo contrario a las suscripciones.
  Mientras que una suscripcion representa el deseo de un usuario de recibir
  publicaciones de una fuente, un bloqueo representa el deseo a no recibir
  publicaciones de una fuente.

  En los casos en que exista una suscripción y un bloqueo a una misma fuente,
  se le dará prioridad siempre a los bloqueos.
  """

  import Ecto.Query

  alias Embers.Feed.Subscriptions.{UserBlock}
  alias Embers.Repo
  alias Embers.Paginator

  @doc """
  Creates a user block

  ## Examples
      iex> create_user_block(1,2)
      {:ok, %UserBlock{}}

      iex> create_user_block(3, 4)
      {:error, %Ecto.Changeset()}
  """
  @spec create_user_block(integer(), integer()) ::
          {:ok, Embers.Feed.Subscriptions.UserBlock.t()} | {:error, Ecto.Changeset.t()}
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

    if(not is_nil(sub)) do
      Repo.delete(sub)
    end
  end

  @spec list_users_blocked_ids_by(integer()) :: [
          Embers.Feed.Subscriptions.UserBlock.t()
        ]
  def list_users_blocked_ids_by(user_id) do
    from(
      block in UserBlock,
      where: block.user_id == ^user_id,
      select: block.source_id
    )
    |> Repo.all()
  end

  @spec list_users_ids_that_blocked(integer()) :: [any()]
  def list_users_ids_that_blocked(user_id) do
    from(
      block in UserBlock,
      where: block.source_id == ^user_id,
      select: block.user_id
    )
    |> Repo.all()
  end

  @spec list_blocks_ids(integer()) :: [any()]
  def list_blocks_ids(user_id) do
    UserBlock
    |> where([block], block.source_id == ^user_id)
    |> select([block], block.user_id)
    |> Repo.all()
  end

  @spec list_blocks_paginated(integer(), list()) :: Embers.Paginator.Page.t()
  def list_blocks_paginated(user_id, opts \\ []) do
    UserBlock
    |> where([block], block.user_id == ^user_id)
    |> join(:left, [block], user in assoc(block, :source))
    |> join(:left, [block, user], meta in assoc(user, :meta))
    |> preload([block, user, meta], user: {user, meta: meta})
    |> Paginator.paginate(opts)
  end

  @spec list_blocks_ids_paginated(integer(), list()) :: Embers.Paginator.Page.t()
  def list_blocks_ids_paginated(user_id, opts \\ []) do
    UserBlock
    |> where([block], block.user_id == ^user_id)
    |> select([block], block.source_id)
    |> Paginator.paginate(opts)
  end

  def blocked?(from, recipient) do
    from(
      block in UserBlock,
      where: block.user_id == ^recipient and block.source_id == ^from
    )
    |> Repo.exists?()
  end
end
