defmodule Embers.Profile do
  @moduledoc """
  The user `Profile` is the one that holds additional data of the `User` account.

  Even if this module is used to interface with that data, it will be referred
  as `Meta`. In the future Meta could be renamed to Profile, and the
  Profile context to Profiles.

  # Avatar and cover
  The avatar and cover files are stored with the user's name and not with a
  unique name, so it's easier to generate urls. In the past we used UUIDs but
  we've found easier to just replace the file and bust client's cache than
  deleting old versions of the file.

  What's stored in the Meta is the timestamp of the last time it was changed,
  and is used to generate versioned urls.
  """

  import Ecto.Query, warn: false
  alias Embers.Repo

  alias Embers.Profile.Meta
  alias Embers.Uploads

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
  def get_meta_for(user_id), do: Repo.get_by(Meta, %{user_id: user_id})
  def get_meta_for!(user_id), do: Repo.get_by!(Meta, %{user_id: user_id})

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

  def remove_avatar(%Meta{user_id: id} = meta) do
    path = Embers.Profile.Uploads.Avatar.fetch_path()
    id = Embers.Helpers.IdHasher.encode(id)

    with :ok <- Uploads.delete("#{path}/#{id}_small.png"),
         :ok <- Uploads.delete("#{path}/#{id}_medium.png"),
         :ok <- Uploads.delete("#{path}/#{id}_large.png"),
         {:ok, _} <- update_meta(meta, %{avatar_version: nil}) do
      :ok
    end
  end

  def remove_cover(%Meta{user_id: id} = meta) do
    path = Embers.Profile.Uploads.Cover.fetch_path()
    id = Embers.Helpers.IdHasher.encode(id)

    with :ok <- Uploads.delete("#{path}/#{id}.jpg"),
         {:ok, _} <- update_meta(meta, %{cover_version: nil}) do
      :ok
    end
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
