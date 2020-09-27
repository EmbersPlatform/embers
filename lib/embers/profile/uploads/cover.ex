defmodule Embers.Profile.Uploads.Cover do
  @moduledoc false
  alias Embers.Uploads

  @path Keyword.get(Application.get_env(:embers, Embers.Profile), :cover_path, "user/cover")

  def upload(cover, %Embers.Accounts.User{} = user) do
    upload(cover, user.id)
  end

  def upload(cover, user_id) do
    if valid?(cover) do
      processed = process(cover)

      with {:ok, _} <-
             Uploads.upload(processed.path, "#{@path}/#{user_id}.jpg", content_type: "image/png") do
        :ok
      else
        error -> error
      end
    else
      {:error, :invalid_format}
    end
  end

  def delete(%Embers.Accounts.User{} = user) do
    delete(user.id)
  end

  def delete(user_id) do
    with :ok <- Uploads.delete("#{@path}/#{user_id}.jpg") do
      :ok
    else
      error -> error
    end
  end

  def fetch_path() do
    @path
  end

  defp valid?(file) do
    [_, type] = String.split(file.content_type, "/")
    ~w(jpg jpeg gif png) |> Enum.member?(type)
  end

  defp process(image) do
    image.path
    |> Mogrify.open()
    |> Mogrify.custom("strip")
    |> Mogrify.resize("960x320")
    |> Mogrify.custom("background", "#1a1b1d")
    |> Mogrify.gravity("center")
    |> Mogrify.extent("960x320")
    |> Mogrify.format("png")
    |> Mogrify.save()
  end
end
