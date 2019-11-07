defmodule Embers.FileStorage.Store.S3 do
  @behaviour Embers.FileStorage.Store

  alias ExAws.S3

  @impl Embers.FileStorage.Store
  def save(file_path, dest_path, opts \\ []) do
    acl = Keyword.get(opts, :acl, :public_read)
    opts = Keyword.put(opts, :acl, acl)

    path = "#{root()}/#{dest_path}"

    res =
      file_path
      |> S3.Upload.stream_file()
      |> S3.upload(bucket(), path, opts)
      |> ExAws.request()

    case res do
      {:ok, _} ->
        {:ok, "#{base_path()}#{dest_path}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl Embers.FileStorage.Store
  def delete(file_path) do
    request = S3.delete_object(bucket(), file_path)

    case ExAws.request(request) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  def base_path do
    Path.join(["https://", host(), bucket(), root())
  end

  defp bucket() do
    Keyword.get(Application.get_env(:embers, Embers.FileStorage), :bucket)
  end

  defp host() do
    Application.get_env(:ex_aws, :s3).host["nyc3"]
  end

  defp root() do
    Application.get_env(:embers, Embers.FileStorage)
    |> Keyword.get(:bucket_root, "uploads")
  end
end
