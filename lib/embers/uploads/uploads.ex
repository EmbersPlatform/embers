defmodule Embers.Uploads do
  @moduledoc """
  Module used to save and delete files uploaded by users.
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

  @spec get_path(binary() | URI.t()) :: binary()
  def get_path(url) do
    url
    |> URI.parse()
    |> do_get_path
  end

  @web_port Application.get_env(:embers, EmbersWeb.Endpoint)[:http][:port]
  defguardp is_localhost(uri) when uri.host == "localhost" and uri.port == @web_port

  defp do_get_path(%URI{path: path} = uri)
       when not is_localhost(uri) do
    [_, _bucket | path] = Path.split(path)
    path |> Enum.join("/")
  end

  defp do_get_path(%URI{path: path}) do
    [_ | path] = Path.split(path)
    path |> Enum.join("/")
  end

  def s3_file_data_from_url(url) do
    %URI{} = uri = URI.parse(url)

    [_slash, bucket | path_parts] = Path.split(uri.path)
    path = Path.join(path_parts)

    %{
      bucket: bucket,
      path: path
    }
  end
end
