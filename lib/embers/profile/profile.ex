defmodule Embers.Profile do
  @moduledoc """
  El Perfil del usuario es el que contiene toda la informacion adicional de la
  cuenta de un usuario, como su descripcion, avatar, etc.
  Este modulo es el utilizado para interactuar con esa informacion, pero la
  mayoria de las veces se hablará de metas, ya que ese es el nombre de la
  relacion con el usuario.

  # Avatares y portadas
  Los archivos de avatares y portadas se guardan con el nombre del usuario y
  no con un nombre único. Esto es a propósito para evitar generar urls cada
  vez que se quiera obtener el nombre de un usuario, y tambien para evitar
  la potencial existencia de avatares y portadas huerfanos.

  Para que los clientes cacheen solo la ultima version de cada avatar y
  portada, lo que se guarda en el perfil del usuario es el timestamp en que
  fueron modificados por ultima vez, y es lo que se utilizara en las url para
  el versionado de los archivos.
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
