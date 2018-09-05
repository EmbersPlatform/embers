defmodule Embers.Profile do
  @moduledoc """
  The Profile context.
  """

  import Ecto.Query, warn: false
  alias Embers.Repo

  alias Embers.Profile.Meta

  @doc """
  Returns the list of user_metas.

  ## Examples

      iex> list_user_metas()
      [%Meta{}, ...]

  """
  def list_user_metas do
    Repo.all(Meta)
  end

  @doc """
  Gets a single meta.

  Raises `Ecto.NoResultsError` if the Meta does not exist.

  ## Examples

      iex> get_meta!(123)
      %Meta{}

      iex> get_meta!(456)
      ** (Ecto.NoResultsError)

  """
  def get_meta!(id), do: Repo.get!(Meta, id)

  @doc """
  Creates a meta.

  ## Examples

      iex> create_meta(%{field: value})
      {:ok, %Meta{}}

      iex> create_meta(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_meta(attrs \\ %{}) do
    %Meta{}
    |> Meta.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a meta.

  ## Examples

      iex> update_meta(meta, %{field: new_value})
      {:ok, %Meta{}}

      iex> update_meta(meta, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_meta(%Meta{} = meta, attrs) do
    meta
    |> Meta.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Meta.

  ## Examples

      iex> delete_meta(meta)
      {:ok, %Meta{}}

      iex> delete_meta(meta)
      {:error, %Ecto.Changeset{}}

  """
  def delete_meta(%Meta{} = meta) do
    Repo.delete(meta)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meta changes.

  ## Examples

      iex> change_meta(meta)
      %Ecto.Changeset{source: %Meta{}}

  """
  def change_meta(%Meta{} = meta) do
    Meta.changeset(meta, %{})
  end
end
