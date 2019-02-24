defmodule Embers.Helpers.OldDbConverter do
  import Ecto.Query
  alias Embers.Repo

  alias Embers.Accounts
  alias Embers.Helpers.PasswordConverter
  alias Embers.Profile.Meta

  def convert_users(source) when is_binary(source) do
    %{"rows" => users} = File.read!(Path.expand(source)) |> Jason.decode!()

    users
    |> Enum.each(&handle_user/1)
  end

  def convert_user_metas(source) when is_binary(source) do
    %{"rows" => metas} = File.read!(Path.expand(source)) |> Jason.decode!()

    metas
    |> Enum.each(&handle_user_meta/1)
  end

  def convert_posts(source) when is_binary(source) do
    %{"rows" => posts} = File.read!(Path.expand(source)) |> Jason.decode!()

    posts
    |> Enum.map(&handle_post/1)
    |> Enum.chunk_every(10000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(Embers.Feed.Post, chunk)
    end)
  end

  defp handle_user(user) do
    %{
      "id" => id,
      "name" => username,
      "email" => email,
      "password" => password
    } = user

    new_user = %{
      "id" => id,
      "username" => username,
      "email" => email,
      "password_hash" => PasswordConverter.convert(password)
    }

    {:ok, _user} = Accounts.create_user(new_user, raw: true, confirm: true)
  end

  defp handle_user_meta(%{"user_id" => user_id} = meta) do
    %{"bio" => bio} = meta

    from(
      m in Meta,
      where: m.user_id == ^user_id,
      update: [set: [bio: ^bio]]
    )
    |> Repo.update_all([])
  end

  defp handle_post(post) do
    %{
      "attachment_type" => attachment_type,
      "attachment_url" => attachment_url,
      "attachment_meta" => attachment_meta
    } = post

    attachment_meta =
      if not is_nil(attachment_meta) do
        Jason.decode!(attachment_meta)
      end || nil

    post_attrs = %{
      id: post["id"],
      user_id: post["user_id"],
      body: post["body"],
      inserted_at: string_to_naive_dt(post["created_at"]),
      updated_at: string_to_naive_dt(post["updated_at"]),
      deleted_at: string_to_naive_dt(post["updated_at"]),
      related_to: post["source_id"],
      old_attachment: %{
        type: attachment_type,
        url: attachment_url,
        meta: attachment_meta
      }
    }

    post_attrs
  end

  defp string_to_naive_dt(date) when is_nil(date), do: nil

  defp string_to_naive_dt(date) do
    date
    |> String.replace(":", "-")
    |> Timex.parse!("%Y-%m-%d %H-%M-%S", :strftime)
  end
end
