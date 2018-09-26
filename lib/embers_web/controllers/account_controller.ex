defmodule EmbersWeb.AccountController do
  use EmbersWeb, :controller

  import EmbersWeb.Authorize
  alias Embers.Accounts
  alias Phauxth.Log

  plug(:guest_check when action in [:new, :create])
  plug(:put_layout, "app_no_js.html")

  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(
        conn,
        %{
          "email" => email
        } = params
      ) do
    case Recaptcha.verify(params["g-recaptcha-response"]) do
      {:ok, _} ->
        key = Phauxth.Token.sign(conn, %{"email" => email})

        case Accounts.create_user(params) do
          {:ok, user} ->
            Log.info(%Log{user: user.id, message: "user created"})
            Accounts.Message.confirm_request(email, key)

            conn
            |> json(%{success: true})

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{
              error:
                Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
                  EmbersWeb.ErrorHelpers.translate_error({msg, opts})
                end)
            })
        end

      {:error, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: %{recaptcha_errors: errors}})
    end
  end
end
