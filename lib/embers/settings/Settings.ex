defmodule Embers.Settings do
  alias Embers.Repo
  alias Embers.Settings.Setting

  def list() do
    Repo.all(Setting)
  end

  def get!(name) when is_binary(name) do
    Repo.get_by!(Setting, name: name)
  end

  def create(attrs) do
    %Setting{}
    |> Setting.changeset(attrs)
    |> Repo.insert()
  end

  def update(name, attrs) when is_binary(name) do
    name
    |> get!()
    |> Setting.changeset(attrs)
    |> Repo.update()
  end

  def delete(name) when is_binary(name) do
    name
    |> get!()
    |> Repo.delete()
  end
end
