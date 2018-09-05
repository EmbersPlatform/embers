defmodule EmbersWeb.ConfirmControllerTest do
  use EmbersWeb.ConnCase

  import EmbersWeb.AuthCase

  setup %{conn: conn} do
    conn = conn |> bypass_through(Embers.Router, :browser) |> get("/")
    add_user("arthur@example.com")
    {:ok, %{conn: conn}}
  end

  test "confirmation succeeds for correct key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: gen_key("arthur@example.com")))
    assert conn.private.phoenix_flash["info"] =~ "account has been confirmed"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: "garbage"))
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "confirmation fails for incorrect email", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: gen_key("gerald@example.com")))
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == session_path(conn, :new)
  end
end
