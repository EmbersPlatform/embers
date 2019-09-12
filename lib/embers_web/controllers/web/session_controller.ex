defmodule EmbersWeb.SessionController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias EmbersWeb.Router.Helpers, as: Routes

  plug(:guest_check when action in [:new, :create, :create_api])
  plug(:put_layout, "app_no_js.html")

  plug(
    :rate_limit_authentication,
    [max_requests: 5, interval_seconds: 60] when action in [:create, :create_api]
  )

  def rate_limit_authentication(conn, options \\ []) do
    id = get_in(conn.params, ["user", "id"])
    options = Keyword.merge(options, bucket_name: "authorization:" <> id)
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = Pow.Plug.change_user(conn)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    id = Map.get(user_params, "id")

    user_params =
      user_params
      |> Map.drop(["id"])
      |> Map.put("email", id_to_email(id))

    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> verify_user()
    |> verify_login()
    |> case do
      {:ok, conn} ->
        user = Pow.Plug.current_user(conn)

        conn
        |> PowPersistentSession.Plug.create(user)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, {conn, reason}} ->
        changeset = Pow.Plug.change_user(conn, conn.params["user"])

        conn
        |> put_flash(:error, reason)
        |> render("new.html", changeset: changeset)

      {:error, conn} ->
        changeset = Pow.Plug.change_user(conn, conn.params["user"])

        conn
        |> put_flash(:error, gettext("invalid credentials"))
        |> render("new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    {:ok, conn} = Pow.Plug.clear_authenticated_user(conn)

    conn
    |> PowPersistentSession.Plug.delete()
    |> put_status(:no_content)
    |> json(nil)
  end

  defp id_to_email(id) do
    case Regex.match?(~r/@/, id) do
      true ->
        id

      false ->
        case Embers.Accounts.get_by_identifier(id) do
          %{email: email} ->
            email

          _ ->
            nil
        end
    end
  end

  defp verify_user({:ok, conn}) do
    conn
    |> Pow.Plug.current_user()
    |> email_confirmed?
    |> case do
      true ->
        {:ok, conn}

      false ->
        {:error, {conn, gettext("account unconfirmed")}}
    end
  end

  defp verify_user({:error, conn}), do: {:error, conn}

  defp verify_login({:error, conn}), do: {:error, conn}

  defp verify_login({:ok, conn}) do
    user = Pow.Plug.current_user(conn)

    if Embers.Moderation.banned?(user) do
      ban = Embers.Moderation.get_active_ban(user.id)

      if Embers.Moderation.ban_expired?(ban) do
        Embers.Moderation.unban_user(user.id)
        {:ok, conn}
      else
        {:error, {conn, format_ban(ban)}}
      end
    else
      {:ok, conn}
    end
  end

  defp email_confirmed?(%{confirmed_at: confirmed?}), do: !is_nil(confirmed?)

  defp format_ban(ban) do
    formatted_duration =
      if is_nil(ban.expires_at) do
        "indefinidamente"
      else
        formatted_date = Timex.format!(ban.expires_at, "{D}/{0M}/{YYYY}")
        "hasta el #{formatted_date}"
      end

    "Tu cuenta se encuentra baneada #{formatted_duration} con el motivo: #{ban.reason}"
  end
end
