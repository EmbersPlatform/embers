defmodule Embers.Profile.Uploads.Avatar do
  @moduledoc false
  alias Embers.Uploads

  @path Keyword.get(Application.get_env(:embers, Embers.Profile), :avatar_path, "user/avatar")

  @doc """
    Converts the avatar to it's `small`, `medium` and `large` versions, and
    saves it to the user's path
  """
  def upload(avatar, %Embers.Accounts.User{} = user) do
    upload(avatar, user.id)
  end

  def upload(avatar, user_id) do
    if valid?(avatar) do
      small = make_small(avatar)
      medium = make_medium(avatar)
      large = make_large(avatar)

      with {:ok, _} <-
             Uploads.upload(small.path, "#{@path}/#{user_id}_small.png", content_type: "image/png"),
           {:ok, _} <-
             Uploads.upload(medium.path, "#{@path}/#{user_id}_medium.png", content_type: "image/png"),
           {:ok, _} <-
             Uploads.upload(large.path, "#{@path}/#{user_id}_large.png", content_type: "image/png") do
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
    meta = Embers.Repo.get_by(Embers.Profile.Meta, user_id: user_id)

    case meta.avatar_version do
      nil ->
        :ok

      _ ->
        with :ok <- Uploads.delete("#{@path}/#{user_id}_small.png"),
             :ok <- Uploads.delete("#{@path}/#{user_id}_medium.png"),
             :ok <- Uploads.delete("#{@path}/#{user_id}_large.png"),
             {:ok, _} <-
               Embers.Profile.Meta.changeset(meta, %{avatar_version: nil}) |> Embers.Repo.update() do
          :ok
        else
          error -> error
        end
    end
  end

  def fetch_path() do
    @path
  end

  defp valid?(file) do
    [_, type] = String.split(file.content_type, "/")
    ~w(jpg jpeg gif png) |> Enum.member?(type)
  end

  defp make_small(image) do
    image.path
    |> Mogrify.open()
    |> Mogrify.custom("strip")
    |> Mogrify.custom("background", "none")
    |> Mogrify.resize("64x64")
    |> Mogrify.gravity("center")
    |> Mogrify.extent("64x64")
    |> Mogrify.format("png")
    |> Mogrify.save()
  end

  defp make_medium(image) do
    image.path
    |> Mogrify.open()
    |> Mogrify.custom("strip")
    |> Mogrify.custom("background", "none")
    |> Mogrify.resize("128x128")
    |> Mogrify.gravity("center")
    |> Mogrify.extent("128x128")
    |> Mogrify.format("png")
    |> Mogrify.save()
  end

  defp make_large(image) do
    image.path
    |> Mogrify.open()
    |> Mogrify.custom("strip")
    |> Mogrify.custom("background", "none")
    |> Mogrify.resize("256x256")
    |> Mogrify.gravity("center")
    |> Mogrify.extent("256x256")
    |> Mogrify.format("png")
    |> Mogrify.save()
  end
end
