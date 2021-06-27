defmodule Embers.FileStorage do
  def save(file, path, opts \\ []) do
    store = get_store()
    store.save(file, path, opts)
  end

  def delete(path) do
    store = get_store()
    store.delete(path)
  end

  def base_path do
    get_store().base_path()
  end

  defp get_store() do
    Application.get_env(:embers, Embers.FileStorage)
    |> Keyword.get(:store, Embers.FileStorage.Local)
  end
end
