defmodule Embers.ProfileTest do
  use Embers.DataCase

  alias Embers.Profile

  describe "user_metas" do
    alias Embers.Profile.Meta

    @valid_attrs %{avatar: "some avatar", bio: "some bio", cover: "some cover"}
    @update_attrs %{avatar: "some updated avatar", bio: "some updated bio", cover: "some updated cover"}
    @invalid_attrs %{avatar: nil, bio: nil, cover: nil}

    def meta_fixture(attrs \\ %{}) do
      {:ok, meta} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profile.create_meta()

      meta
    end

    test "list_user_metas/0 returns all user_metas" do
      meta = meta_fixture()
      assert Profile.list_user_metas() == [meta]
    end

    test "get_meta!/1 returns the meta with given id" do
      meta = meta_fixture()
      assert Profile.get_meta!(meta.id) == meta
    end

    test "create_meta/1 with valid data creates a meta" do
      assert {:ok, %Meta{} = meta} = Profile.create_meta(@valid_attrs)
      assert meta.avatar == "some avatar"
      assert meta.bio == "some bio"
      assert meta.cover == "some cover"
    end

    test "create_meta/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profile.create_meta(@invalid_attrs)
    end

    test "update_meta/2 with valid data updates the meta" do
      meta = meta_fixture()
      assert {:ok, meta} = Profile.update_meta(meta, @update_attrs)
      assert %Meta{} = meta
      assert meta.avatar == "some updated avatar"
      assert meta.bio == "some updated bio"
      assert meta.cover == "some updated cover"
    end

    test "update_meta/2 with invalid data returns error changeset" do
      meta = meta_fixture()
      assert {:error, %Ecto.Changeset{}} = Profile.update_meta(meta, @invalid_attrs)
      assert meta == Profile.get_meta!(meta.id)
    end

    test "delete_meta/1 deletes the meta" do
      meta = meta_fixture()
      assert {:ok, %Meta{}} = Profile.delete_meta(meta)
      assert_raise Ecto.NoResultsError, fn -> Profile.get_meta!(meta.id) end
    end

    test "change_meta/1 returns a meta changeset" do
      meta = meta_fixture()
      assert %Ecto.Changeset{} = Profile.change_meta(meta)
    end
  end
end
