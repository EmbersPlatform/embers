defmodule Embers.FileStorage.Store.Local do
  @behaviour Embers.FileStorage.Store

  @impl Embers.FileStorage.Store
  def save(file_path, dest_path, _opts \\ []) do
    expanded_dest_path = Path.expand("./uploads/" <> dest_path)
    with :ok <- File.cp(file_path, expanded_dest_path), do: {:ok, dest_path}
  end

  @impl Embers.FileStorage.Store
  def delete(file_path) do
    Path.expand("./uploads/" <> file_path)

    case File.rm(Path.expand("./uploads/" <> file_path)) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      error -> error
    end
  end

  def base_path do
    "/"
  end
end
