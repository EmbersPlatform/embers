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

    update_auto_increment("users")
  end

  def convert_user_metas(source) when is_binary(source) do
    %{"rows" => metas} = File.read!(Path.expand(source)) |> Jason.decode!()

    metas
    |> Enum.each(&handle_user_meta/1)

    update_auto_increment("user_metas")
  end

  def convert_posts(source) when is_binary(source) do
    %{"rows" => posts} = File.read!(Path.expand(source)) |> Jason.decode!()

    posts
    |> Stream.map(&handle_post/1)
    |> Enum.each(fn
      %{nsfw: nsfw, post: %{related_to_id: nil} = post} ->
        post = struct(Embers.Posts.Post, post)
        {:ok, post} = Repo.insert(post, on_conflict: :nothing)

        if nsfw == 1 do
          Embers.Tags.add_tag(post, "nsfw")
        end

      _ ->
        nil
    end)

    update_auto_increment("posts")
  end

  def convert_comments(source) when is_binary(source) do
    %{"rows" => comments} = File.read!(Path.expand(source)) |> Jason.decode!()

    posts_ids =
      from(post in "posts",
        select: post.id
      )
      |> Repo.all()

    users_ids =
      from(user in "users",
        select: user.id
      )
      |> Repo.all()

    comments
    |> Enum.map(&handle_comment/1)
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk ->
      chunk =
        Enum.reduce(chunk, [], fn comment, acc ->
          if is_integer(comment.parent_id) and comment.parent_id in posts_ids and
               comment.user_id in users_ids do
            [comment] ++ acc
          else
            acc
          end
        end)

      Repo.insert_all(Embers.Posts.Post, chunk)
    end)

    update_auto_increment("posts")
  end

  def convert_reactions(source) when is_binary(source) do
    %{"rows" => reactions} = File.read!(Path.expand(source)) |> Jason.decode!()

    posts_ids =
      from(post in "posts",
        select: post.id
      )
      |> Repo.all()

    users_ids =
      from(user in "users",
        select: user.id
      )
      |> Repo.all()

    reactions
    |> Enum.map(&handle_reaction/1)
    |> Enum.uniq()
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk ->
      chunk =
        chunk
        |> Enum.reduce([], fn reaction, acc ->
          if !is_nil(reaction) and reaction.post_id in posts_ids and reaction.user_id in users_ids do
            [reaction] ++ acc
          else
            acc
          end
        end)
        |> Enum.map(fn r ->
          %{
            user_id: r.user_id,
            post_id: r.post_id,
            name: r.name,
            inserted_at: current_date_naive(),
            updated_at: current_date_naive()
          }
        end)

      Repo.insert_all(Embers.Reactions.Reaction, chunk)
    end)

    update_auto_increment("reactions")
  end

  def convert_tags(source) when is_binary(source) do
    %{"rows" => tags} = File.read!(Path.expand(source)) |> Jason.decode!()

    tags
    |> Enum.map(fn tag ->
      %{
        id: tag["id"],
        name: tag["name"]
      }
    end)
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(Embers.Tags.Tag, chunk, on_conflict: :nothing)
    end)

    update_auto_increment("tags")
  end

  def convert_tag_post(source) when is_binary(source) do
    %{"rows" => tags} = File.read!(Path.expand(source)) |> Jason.decode!()

    posts_ids =
      from(post in "posts",
        select: post.id
      )
      |> Repo.all()

    tags_ids =
      from(tag in "tags",
        select: tag.id
      )
      |> Repo.all()

    tags
    |> Enum.map(fn x ->
      %{
        tag_id: x["tag_id"],
        post_id: x["post_id"],
        inserted_at: current_date_naive(),
        updated_at: current_date_naive()
      }
    end)
    |> Enum.uniq()
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk ->
      chunk
      |> Enum.reduce([], fn tag, acc ->
        if !is_nil(tag) and tag.post_id in posts_ids and tag.tag_id in tags_ids do
          [tag] ++ acc
        else
          acc
        end
      end)

      Repo.insert_all(Embers.Tags.TagPost, chunk, on_conflict: :nothing)
    end)

    update_auto_increment("tags_posts")
  end

  def convert_favorites(source) do
    %{"rows" => favs} = File.read!(Path.expand(source)) |> Jason.decode!()

    favs
    |> Stream.map(fn f ->
      %{
        user_id: f["user_id"],
        post_id: f["post_id"],
        inserted_at: current_date_naive(),
        updated_at: current_date_naive()
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(Embers.Favorites.Favorite, chunk, on_conflict: :nothing)
    end)

    update_auto_increment("favorites")
  end

  def convert_follows(source) do
    %{"rows" => follows} = File.read!(Path.expand(source)) |> Jason.decode!()

    follows
    |> Stream.map(fn f ->
      %{
        "follower_id" => user_id,
        "followed_id" => source_id
      } = f

      %{
        user_id: user_id,
        source_id: source_id,
        inserted_at: current_date_naive(),
        updated_at: current_date_naive()
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(Embers.Subscriptions.UserSubscription, chunk, on_conflict: :nothing)
    end)

    update_auto_increment("user_subscriptions")
  end

  def convert_blocks(source) do
    %{"rows" => blocks} = File.read!(Path.expand(source)) |> Jason.decode!()

    blocks
    |> Stream.map(fn f ->
      %{
        "user_id" => user_id,
        "blockable_id" => source_id
      } = f

      %{
        user_id: user_id,
        source_id: source_id,
        inserted_at: current_date_naive(),
        updated_at: current_date_naive()
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(fn chunk ->
      Repo.insert_all(Embers.Subscriptions.UserBlock, chunk, on_conflict: :nothing)
    end)

    update_auto_increment("user_blocks")
  end

  defp handle_reaction(reaction) do
    %{
      "user_id" => user_id,
      "reactable_type" => reactable_type,
      "reactable_id" => post_id,
      "reaction" => name
    } = reaction

    unless reactable_type !== "App\\Post" do
      %{
        user_id: user_id,
        post_id: post_id,
        name: translate_reaction(name)
      }
    end
  end

  defp handle_comment(comment) do
    %{
      "user_id" => user_id,
      "body" => body,
      "commentable_id" => parent_id,
      "created_at" => inserted_at,
      "updated_at" => updated_at,
      "deleted_at" => deleted_at
    } = comment

    %{
      user_id: user_id,
      body: body,
      parent_id: parent_id,
      nesting_level: 1,
      inserted_at: string_to_naive_dt(inserted_at),
      updated_at: string_to_naive_dt(updated_at),
      deleted_at: string_to_naive_dt(deleted_at)
    }
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
      "password_hash" => PasswordConverter.convert(password),
      "confirmed_at" => current_date_naive()
    }

    {:ok, user} = Accounts.create_user(new_user, raw: true, confirm: true)
    Accounts.confirm_user(user)
  end

  defp handle_user_meta(%{"user_id" => user_id} = meta) do
    %{"bio" => bio, "avatar" => avatar, "cover" => cover} = meta

    avatar =
      unless is_nil(avatar) do
        "legacy:#{avatar}"
      end

    cover =
      unless is_nil(cover) do
        "legacy:#{cover}"
      end

    from(
      m in Meta,
      where: m.user_id == ^user_id,
      update: [set: [bio: ^bio, avatar_version: ^avatar, cover_version: ^cover]]
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
      deleted_at: string_to_naive_dt(post["deleted_at"]),
      related_to_id: post["share_source"],
      old_attachment: %{
        type: attachment_type,
        url: attachment_url,
        meta: attachment_meta
      }
    }

    %{nsfw: post["nsfw"], post: post_attrs}
  end

  defp string_to_naive_dt(date) when is_nil(date), do: nil

  defp string_to_naive_dt(date) do
    date
    |> String.replace(":", "-")
    |> Timex.parse!("%Y-%m-%d %H-%M-%S", :strftime)
  end

  defp current_date_naive do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  defp translate_reaction(name) do
    case name do
      "angry_sock" -> "angry"
      same -> same
    end
  end

  def update_auto_increment(table) do
    id = Repo.one(from(row in table, order_by: [desc: row.id], select: row.id, limit: 1))
    query = "ALTER SEQUENCE #{table}_id_seq RESTART WITH #{id + 1}"

    Ecto.Adapters.SQL.query!(Repo, query, [])
  end
end
