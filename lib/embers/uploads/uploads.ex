defmodule Embers.Uploads do
  @moduledoc """
  Este modulo se encarga de guardar y eliminar archivos subidos por los
  usuarios.
  """

  alias Embers.FileStorage

  @enforce_keys [:path, :url]
  defstruct path: nil,
            url: nil

  @type t() :: %__MODULE__{
          path: String.t(),
          url: String.t()
        }

  @spec upload(any, binary, keyword) :: {:ok, t()} | {:error, any}
  def upload(file, path, opts \\ []) do
    case FileStorage.save(file, path, opts) do
      {:ok, url} ->
        {:ok,
         %__MODULE__{
           path: "#{path}",
           url: "#{url}"
         }}

      error ->
        error
    end
  end

  @doc """
  Tries to delete a file in `path`.
  """
  def delete(path) do
    FileStorage.delete(path)
  end

  def base_path do
    FileStorage.base_path()
  end

  @spec parse_url(binary() | URI.t()) :: binary()
  def parse_url(url) do
    url
    |> URI.parse()
    |> do_parse
  end

  defp do_parse(%URI{host: host, path: path}) when not is_nil(host) and host != "localhost" do
    [_ | [_bucket | path]] = Path.split(path)
    path |> Enum.join("/")
  end

  defp do_parse(%URI{path: path}) do
    [_ | path] = Path.split(path)
    path |> Enum.join("/")
  end
end
