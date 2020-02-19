defmodule EmbersWeb.AccountController do
  @moduledoc false
  use EmbersWeb, :controller

  import EmbersWeb.Authorize

  alias Embers.Accounts
  alias EmbersWeb.Auth.Token
  alias EmbersWeb.Email
  alias EmbersWeb.Router.Helpers, as: Routes

  plug(:guest_check when action in [:new, :create])

  plug(
    :rate_limit_signup,
    [max_requests: 5, interval_seconds: 60] when action in [:create]
  )

  def rate_limit_signup(conn, options \\ []) do
    ip = conn.remote_ip
    ip_string = ip |> :inet_parse.ntoa |> to_string()
    options = Keyword.merge(options, bucket_name: "signup:#{ip_string}")
    EmbersWeb.RateLimit.rate_limit(conn, options)
  end

  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", page_title: "Registrarse", changeset: changeset)
  end

  @accounts_limit_time :timer.hours(24) * 7
  @accounts_limit 2

  def create(conn, params) do
    email = get_in(params, ["user", "email"])

    ip = conn.remote_ip
    ip_string = ip |> :inet_parse.ntoa |> to_string()

    rate_limit = EmbersWeb.RateLimit.peek_rate(
      "signup_success:#{ip_string}",
      @accounts_limit_time,
      @accounts_limit
    )

    with :ok <- rate_limit,
         {:ok, _} <- Recaptcha.verify(params["g-recaptcha-response"]),
         {:ok, _user} <- Accounts.create_user(params["user"]) do
      send_confirmation_email(email)

      ExRated.check_rate("signup_success:#{ip_string}", @accounts_limit_time, @accounts_limit)

      conn
      |> put_flash(
        :info,
        "Tu cuenta ha sido creada, pero antes debes activarla.
        Te enviamos un email con un enlace para activarla."
      )
      |> redirect(to: Routes.session_path(conn, :new))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Hubo un error al crear la cuenta, por favor revisa
          los errores debajo.")
        |> render("new.html", page_title: "Registrarse", changeset: changeset)

      {:error, _recaptcha_error} ->
        conn
        |> put_flash(:error, gettext("There was an error, please try again later"))
        |> redirect(to: Routes.account_path(conn, :new))

      :rate_limited ->
        conn
        |> put_flash(:error, gettext("You have to wait a few days before creating another account"))
        |> redirect(to: Routes.account_path(conn, :new))
    end
  end

  defp send_confirmation_email(email) do
    key = Token.sign(%{"email" => email})
    Email.confirm_request(email, key)
  end
end
