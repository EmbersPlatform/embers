defmodule EmbersWeb.MetaControllerTest do
  use EmbersWeb.ConnCase

  alias Embers.Profile
  alias Embers.Profile.Meta

  @create_attrs %{avatar: "some avatar", bio: "some bio", cover: "some cover"}
  @update_attrs %{avatar: "some updated avatar", bio: "some updated bio", cover: "some updated cover"}
  @invalid_attrs %{avatar: nil, bio: nil, cover: nil}

  def fixture(:meta) do
    {:ok, meta} = Profile.create_meta(@create_attrs)
    meta
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_metas", %{conn: conn} do
      conn = get conn, meta_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create meta" do
    test "renders meta when data is valid", %{conn: conn} do
      conn = post conn, meta_path(conn, :create), meta: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, meta_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "avatar" => "some avatar",
        "bio" => "some bio",
        "cover" => "some cover"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, meta_path(conn, :create), meta: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update meta" do
    setup [:create_meta]

    test "renders meta when data is valid", %{conn: conn, meta: %Meta{id: id} = meta} do
      conn = put conn, meta_path(conn, :update, meta), meta: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, meta_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "avatar" => "some updated avatar",
        "bio" => "some updated bio",
        "cover" => "some updated cover"}
    end

    test "renders errors when data is invalid", %{conn: conn, meta: meta} do
      conn = put conn, meta_path(conn, :update, meta), meta: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete meta" do
    setup [:create_meta]

    test "deletes chosen meta", %{conn: conn, meta: meta} do
      conn = delete conn, meta_path(conn, :delete, meta)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, meta_path(conn, :show, meta)
      end
    end
  end

  defp create_meta(_) do
    meta = fixture(:meta)
    {:ok, meta: meta}
  end
end
