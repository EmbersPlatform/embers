defmodule Embers.Posts.PostTest do
  use Embers.DataCase

  alias Embers.Posts.Post

  @valid_attrs %{
    body: "valid body!",
    user_id: 1
  }

  describe "Embers.Posts.Post.changeset/2" do
    test "builds post" do
      changeset = Post.changeset(%Post{}, @valid_attrs)

      assert changeset.valid?
    end

    test "user_id is required" do
      changeset = Post.changeset(%Post{}, %{user_id: nil})

      refute changeset.valid?
      assert {:user_id, {"can't be blank", [validation: :required]}} in changeset.errors
    end

    test "body is required if there isn't any other content present" do
      changeset = Post.changeset(%Post{}, %{user_id: 1})
      refute changeset.valid?
      assert {:body, "can't be blank"} in changeset.errors
    end

    test "body is optional if there are Medias" do
      changeset = Post.changeset(%Post{}, %{user_id: 1, media_count: 1})
      assert changeset.valid?
    end

    test "body is optional if there are Links" do
      changeset = Post.changeset(%Post{}, %{user_id: 1, links_count: 1})
      assert changeset.valid?
    end

    test "body is optional if post is a share" do
      changeset = Post.changeset(%Post{}, %{user_id: 1, related_to_id: 1})
      assert changeset.valid?
    end

    test "trims body" do
      body = "     body     "
      changeset = Post.changeset(%Post{}, %{user_id: 1, body: body})

      assert changeset.changes.body == String.trim(body)
    end

    test "only one of parent_id and related_to_id can be present" do
      changeset = Post.changeset(%Post{}, %{user_id: 1, parent_id: 1, related_to_id: 1})

      refute changeset.valid?
      assert(
        {
          :invalid_data,
          "only one of `parent_id` and `related_to_id` can be present at the same time"
        } in changeset.errors)
    end
  end
end
