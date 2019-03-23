defmodule Embers.Profile.Uploads.Avatar do
  alias Embers.Helpers.IdHasher
  alias Embers.Uploads

  @bucket "local"
  @path "/user/avatar"

  def upload(avatar, %Embers.Accounts.User{} = user) do
    upload(avatar, user.id)
  end
  def upload(avatar, user_id) when is_integer(user_id) do
    if(valid?(avatar)) do
      small = make_small(avatar)
      medium = make_medium(avatar)
      large = make_large(avatar)

      id = IdHasher.encode(user_id)

      with {:ok, _} <- Uploads.upload(small.path, @bucket, "#{@path}/#{id}_small.png"),
          {:ok, _} <- Uploads.upload(medium.path, @bucket, "#{@path}/#{id}_medium.png"),
          {:ok, _} <- Uploads.upload(large.path, @bucket, "#{@path}/#{id}_large.png") do
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
    with :ok <- Uploads.delete(@bucket, "#{@path}/#{id}_small.png"),
         :ok <- Uploads.delete(@bucket, "#{@path}/#{id}_medium.png"),
         :ok <- Uploads.delete(@bucket, "#{@path}/#{id}_large.png") do
      :ok
    else
      error -> error
    end
  end

  defp valid?(file) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.filename))
  end

  defp make_small(image) do
    image.path
      |> Mogrify.open()
      |> Mogrify.custom("strip")
      |> Mogrify.resize("64x64")
      |> Mogrify.custom("background", "#1a1b1d")
      |> Mogrify.gravity("center")
      |> Mogrify.extent("64x64")
      |> Mogrify.format("png")
      |> Mogrify.save()
  end

  defp make_medium(image) do
      image.path
      |> Mogrify.open()
      |> Mogrify.custom("strip")
      |> Mogrify.resize("128x128")
      |> Mogrify.custom("background", "#1a1b1d")
      |> Mogrify.gravity("center")
      |> Mogrify.extent("128x128")
      |> Mogrify.format("png")
      |> Mogrify.save()
  end

  defp make_large(image) do
      image.path
      |> Mogrify.open()
      |> Mogrify.custom("strip")
      |> Mogrify.resize("256x256")
      |> Mogrify.custom("background", "#1a1b1d")
      |> Mogrify.gravity("center")
      |> Mogrify.extent("256x256")
      |> Mogrify.format("png")
      |> Mogrify.save()
  end
end
