defmodule Embers.Profile.Uploads.Avatar do
  @moduledoc false
  alias Embers.Helpers.IdHasher
  alias Embers.Uploads

  @path Keyword.get(Application.get_env(:embers, Embers.Profile), :avatar_path, "user/avatar")

  def upload(avatar, %Embers.Accounts.User{} = user) do
    upload(avatar, user.id)
  end

  def upload(avatar, user_id) when is_integer(user_id) do
    if valid?(avatar) do
      small = make_small(avatar)
      medium = make_medium(avatar)
      large = make_large(avatar)

      id = IdHasher.encode(user_id)

      with {:ok, _} <-
             Uploads.upload(small.path, "#{@path}/#{id}_small.png", content_type: "image/png"),
           {:ok, _} <-
             Uploads.upload(medium.path, "#{@path}/#{id}_medium.png", content_type: "image/png"),
           {:ok, _} <-
             Uploads.upload(large.path, "#{@path}/#{id}_large.png", content_type: "image/png") do
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

  def delete(user_id) when is_integer(user_id) do
    id = IdHasher.encode(user_id)
    meta = Embers.Repo.get_by(Embers.Profile.Meta, user_id: user_id)

    case meta.avatar_version do
      nil ->
        :ok

      _ ->
        with :ok <- Uploads.delete("#{@path}/#{id}_small.png"),
             :ok <- Uploads.delete("#{@path}/#{id}_medium.png"),
             :ok <- Uploads.delete("#{@path}/#{id}_large.png"),
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
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.filename))
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
