defmodule Embers.Posts.PostTest do
  use Embers.DataCase

  import Embers.Factory

  alias Embers.Posts.Post
  alias Embers.Repo

  @valid_attrs %{
    body: "valid body!",
    user_id: 1
  }

  describe "changeset/2" do
    test "builds post" do
      changeset = Post.changeset(%Post{}, @valid_attrs)

      assert changeset.valid?
    end

    test "user_id is required" do
      changeset = Post.changeset(%Post{}, %{user_id: nil})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).user_id
    end

    test "user must exist" do
      user = insert(:user)

      post =
        Post.changeset(%Post{}, @valid_attrs |> Map.put(:user_id, user.id))
        |> Repo.insert
      bad_post =
        Post.changeset(%Post{}, @valid_attrs |> Map.put(:user_id, -1))
        |> Repo.insert

      assert {:ok, %Post{}} = post
      assert {:error, bad_changeset} = bad_post
      refute bad_changeset.valid?
      assert "does not exist" in errors_on(bad_changeset).user
    end

    test "body is required if there isn't any other content present" do
      changeset = Post.changeset(%Post{}, %{user_id: 1})
      refute changeset.valid?
      assert %{body: ["can't be blank"]} = errors_on(changeset)
    end

    test "body is optional if post is a share" do
      changeset = Post.changeset(%Post{}, %{user_id: 1, related_to_id: 1})
      assert changeset.valid?
    end

    test "body is optional if there's a media" do
      media = insert(:media_item)
      changeset = Post.changeset(%Post{}, %{user_id: 1, media: [media]})

      assert changeset.valid?
    end

    test "body is optional if there's a link" do
      link = insert(:link)
      changeset = Post.changeset(%Post{}, %{user_id: 1, links: [link]})

      assert changeset.valid?
    end

    test "trims body" do
      body = "     body     "
      changeset = Post.changeset(%Post{}, %{user_id: 1, body: body})

      assert changeset.changes.body == String.trim(body)
    end

    test "validates body lengths" do
      min_changeset = Post.changeset(%Post{}, %{user_id: 1, body: ""})
      max_changeset = Post.changeset(%Post{}, %{user_id: 1, body: String.duplicate("a", 1601)})

      assert "can't be blank" in errors_on(min_changeset).body
      assert "should be at most 1600 character(s)" in errors_on(max_changeset).body
    end

    test "only one of parent_id and related_to_id can be present" do
      changeset = Post.changeset(%Post{}, %{
        user_id: 1,
        parent_id: 1,
        related_to_id: 1
      })

      refute changeset.valid?
      assert %{
        invalid_data:
          ["only one of `parent_id` and `related_to_id` can be present at the same time"]
        } = errors_on(changeset)
    end

    test "parent post must exist" do
      post = insert(:post)
      changeset = Post.changeset(%Post{}, %{user_id: 1, body: "test", parent_id: post.id})
      bad_changeset = Post.changeset(%Post{}, %{user_id: 1, body: "test", parent_id: -1})

      assert changeset.valid?
      refute bad_changeset.valid?
      assert ["parent post does not exist"] = errors_on(bad_changeset).parent
    end

    test "related post must exist" do
      user = insert(:user)
      post = insert(:post)
      changeset = Post.changeset(%Post{}, %{user_id: user.id, related_to_id: post.id})
      bad_post =
        Post.changeset(%Post{}, %{user_id: user.id, related_to_id: -1})
        |> Repo.insert()

      assert changeset.valid?
      assert {:error, bad_changeset} = bad_post
      refute bad_changeset.valid?
      assert ["does not exist"] = errors_on(bad_changeset).related_to
    end

    test "validates media assocs" do
      medias = insert_list(4, :media_item)
      changeset = Post.changeset(%Post{}, %{user_id: 1, media: medias})

      assert changeset.valid?
    end

    test "cant have more than 4 medias" do
      medias = insert_list(5, :media_item)
      changeset = Post.changeset(%Post{}, %{user_id: 1, media: medias})

      refute changeset.valid?
      assert "should have at most 4 item(s)" in errors_on(changeset).media
    end

    test "tags assoc is successful" do
      tag = insert(:tag)
      user = insert(:user)

      changeset = Post.changeset(%Post{}, %{user_id: user.id, body: "test", tags: [tag]})

      assert changeset.valid?

      {:ok, post} = Repo.insert(changeset)
      assert [%Embers.Tags.Tag{}] = post.tags
    end

    test "link assoc is successful" do
      link = insert(:link)
      user = insert(:user)

      changeset = Post.changeset(%Post{}, %{user_id: user.id, links: [link]})

      assert changeset.valid?

      {:ok, post} = Repo.insert(changeset)
      assert [%Embers.Links.Link{}] = post.links
    end
  end

  describe "create_changeset/2" do
    test "increments the replies_count" do
      user = insert(:user)
      parent = insert(:post)
      changeset =
        Post.create_changeset(
          %Post{},
          %{
            user_id: user.id,
            body: "test",
            parent_id: parent.id
          }
        )

      assert {:ok, _post} = Repo.insert(changeset)
      post = Repo.get(Post, parent.id)
      assert post.replies_count == 1
    end

    test "increments the shares_count" do
      user = insert(:user)
      related = insert(:post)
      changeset =
        Post.create_changeset(
          %Post{},
          %{
            user_id: user.id,
            body: "test",
            related_to_id: related.id
          }
        )

      assert {:ok, _post} = Repo.insert(changeset)
      post = Repo.get(Post, related.id)
      assert post.shares_count == 1
    end
  end

  describe "parse_tags/1" do
    tests = [
      %{
        text: "#test",
        expected: ~w(test)
      },
      %{
        text: "#hola #mundo",
        expected: ~w(hola mundo)
      },
      %{
        text: "hola#mundo",
        expected: []
      },
      %{
        text: nil,
        expected: []
      }
    ]

    Enum.each(tests, fn test ->
      assert Post.parse_tags(test.text) == test.expected
    end)
  end
end
