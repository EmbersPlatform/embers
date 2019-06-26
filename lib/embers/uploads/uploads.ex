defmodule Embers.Uploads do
  @moduledoc """
  Este modulo se encarga de guardar y eliminar archivos subidos por los
  usuarios.

  Por el momento esto se hace de dos formas: subiendolos al almacenamiento
  local(en el directorio del proyecto), o a un servicio compatible con
  AWS S3, en el bucket especificado en la configuracion.

  ## Subir a S3
  La subida de archivas a S3 se realiza con el modulo `ExAws.S3`, la
  configuración por lo tanto es la misma, por ejemplo:

      config :ex_aws, :s3, %{
        access_key_id: "ACCESS_KEY",
        secret_access_key: "SECRET_KEY",
        scheme: "https://",
        host: %{"nyc3" => "embers-host.nyc3.digitaloceanspaces.com"},
        region: "nyc3"
      }
  """

  alias ExAws.S3

  @enforce_keys [:path, :url]
  defstruct path: nil,
            url: nil

  @type t() :: %__MODULE__{
          path: String.t(),
          url: String.t()
        }

  @doc """
  Uploads a file in `source` to `path` in the given `bucket`.

  When `bucket` is `"local"` the file will be copied to `"./uploads"` folder.
  Otherwise it'll try to upload the file using `ExAws.S3`.

  Returns `{:ok, %Embers.Uploads{}}` on success or `{:error, reason}`

  Options:
  - `:acl`: The acl permissions for the file uploaded to S3. Defaults to `:public_read`

  ## Example
        iex> upload(file, "uploads", "media/file.ext")
        {
          :ok,
          %Embers.Uploads{
            url: "embers-host.nyc2.digitaloceanspaces.com/uploads/media/file.ext",
            path: "media/file.ext"
          }
        }
  """
  @spec upload(String.t(), String.t(), String.t(), keyword()) :: {:ok, __MODULE__.t()}
  def upload(source, bucket, path, opts \\ [])

  def upload(source, "local", path, _opts) do
    dest_path = Path.expand("./uploads/#{path}")
    File.cp(source, dest_path)

    {:ok,
     %__MODULE__{
       path: "#{path}",
       url: "/#{path}"
     }}
  end

  def upload(source, bucket, path, opts) do
    acl = Keyword.get(opts, :acl, :public_read)
    opts = Keyword.put(opts, :acl, acl)

    res =
      source
      |> S3.Upload.stream_file()
      |> S3.upload(bucket, path, opts)
      |> ExAws.request()

    case res do
      {:ok, _} ->
        {:ok,
         %__MODULE__{
           path: path,
           url: "https://#{Application.get_env(:ex_aws, :s3).host["nyc3"]}/uploads/#{path}"
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Tries to delete a file in `path` from the given `bucket`.
  """
  def delete("local", "/" <> path) do
    delete("local", path)
  end

  def delete("local", path) do
    File.rm(Path.expand("uploads/" <> path))
  end

  def delete(bucket, path) do
    request = S3.delete_object(bucket, path)

    case ExAws.request(request) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @spec parse_url(binary() | URI.t()) :: {binary(), binary()}
  def parse_url(url) do
    url
    |> URI.parse()
    |> do_parse
  end

  defp do_parse(%URI{host: host, path: path}) when not is_nil(host) and host != "localhost" do
    [_ | [bucket | path]] = Path.split(path)
    {bucket, path |> Enum.join("/")}
  end

  defp do_parse(%URI{path: path}) do
    [_ | path] = Path.split(path)
    {"local", path |> Enum.join("/")}
  end
end
