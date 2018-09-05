defmodule EmbersWeb.PasswordResetControllerTest do
  use EmbersWeb.ConnCase

  import EmbersWeb.AuthCase
  alias Embers.Accounts

  @update_attrs %{email: "gladys@example.com", password: "^hEsdg*F899"}

  setup %{conn: conn} do
    conn = conn |> bypass_through(EmbersWeb.Router, :browser) |> get("/")
    user = add_reset_user("gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  defp get_user do
    Accounts.get_by(%{"email" => "gladys@example.com"})
  end

  test "user can create a password reset request", %{conn: conn} do
    valid_attrs = %{email: "gladys@example.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: valid_attrs)
    assert conn.private.phoenix_flash["info"] =~ "your inbox for instructions"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "create function fails for no user", %{conn: conn} do
    invalid_attrs = %{email: "prettylady@example.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: invalid_attrs)
    assert conn.private.phoenix_flash["info"] =~ "your inbox for instructions"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "reset password succeeds for correct key", %{conn: conn} do
    valid_attrs = Map.put(@update_attrs, :key, gen_key("gladys@example.com"))
    reset_conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)
    assert reset_conn.private.phoenix_flash["info"] =~ "password has been reset"
    assert redirected_to(reset_conn) == session_path(conn, :new)
    conn = post(conn, session_path(conn, :create), session: @update_attrs)
    assert redirected_to(conn) == user_path(conn, :index)
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    invalid_attrs = %{email: "gladys@example.com", password: "^hEsdg*F899", key: "garbage"}
    conn = put(conn, password_reset_path(conn, :update), password_reset: invalid_attrs)
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
  end

  test "sessions are deleted when user updates password", %{conn: conn, user: user} do
    add_phauxth_session(conn, user)
    assert get_user().sessions != %{}
    valid_attrs = Map.put(@update_attrs, :key, gen_key("gladys@example.com"))
    reset_conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)
    refute get_session(reset_conn, :phauxth_session_id)
    assert get_user().sessions == %{}
  end
end
