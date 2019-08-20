defmodule Embers.PostsTest do
  use Embers.DataCase

  import Embers.Factory

  alias Embers.Posts
  alias Embers.Posts.Post

  describe "get_post/1" do
    test "gets a post by id" do
      post = insert(:post)
      {:ok, retrieved_post} = Posts.get_post(post.id)

      assert retrieved_post.id == post.id
    end

    test "returns {:error, :not_found} if post does not exist" do
      assert {:error, :not_found} = Posts.get_post(nil)
      assert {:error, :not_found} = Posts.get_post(-1)
    end

    test "loads user with meta" do
      user = insert(:user)
      insert(:meta, user: user)
      %{id: post_id} = insert(:post, user: user)
      {:ok, post} = Posts.get_post(post_id)

      assert %{
        user: %Embers.Accounts.User{
          meta: %Embers.Profile.Meta{}
          }
        } = post
    end

    test "loads related post" do
      original_post = insert(:post)
      post = insert(:post, related_to: original_post)

      {:ok, retrieved_post} = Posts.get_post(post.id)
      assert retrieved_post.related_to.id == original_post.id
    end

    test "loads related post with user and meta" do
      original_user = insert(:user, meta: insert(:meta))
      original_post = insert(:post, user: original_user)
      %{id: post_id} = insert(:post, related_to: original_post)

      {:ok, post} = Posts.get_post(post_id)
      assert %{
        related_to: %Post{
            user: %Embers.Accounts.User{
            meta: %Embers.Profile.Meta{}
            }
          }
        } = post
    end

    test "loads media" do
      media = insert(:media_item)
      %{id: post_id} = insert(:post, media: [media])

      {:ok, post} = Posts.get_post(post_id)
      assert %{
          media: [%Embers.Media.MediaItem{}]
        } = post
    end

    test "loads links" do
      link = insert(:link)
      %{id: post_id} = insert(:post, links: [link])

      {:ok, post} = Posts.get_post(post_id)
      assert %{
          links: [%Embers.Links.Link{}]
        } = post
    end

    test "loads tags" do
      tag = insert(:tag)
      post = insert(:post)
      insert(:tag_post, tag: tag, post: post)

      {:ok, post} = Posts.get_post(post.id)
      assert %{
        tags: [%Embers.Tags.Tag{}]
      } = post
    end

    test "loads reactions" do
      post = insert(:post)
      reaction = insert(:reaction, post: post)

      {:ok, post} = Posts.get_post(post.id)
      assert %{
        reactions: [%Embers.Reactions.Reaction{}]
      } = post
    end
  end

  describe "create_post" do
    test "creates a post" do
      user = insert(:user)
      assert {:ok, %Post{}} =
          Posts.create_post(%{user_id: user.id, body: "test"}, emit_event?: false)
    end

    test "return {:error, reason} tuple on error" do
      assert {:error, _reason} = Posts.create_post(%{}, emit_event?: false)
    end
  end
end
