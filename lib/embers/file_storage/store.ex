defmodule Embers.FileStorage.Store do
  @callback save(file_path :: String.t(), dest_path :: String.t(), keyword()) ::
              {:ok, binary()}
              | {:error, any()}

  @callback(delete(path :: String.t()) :: :ok, {:error, atom()})
end
