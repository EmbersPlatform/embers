defmodule EmbersWeb.Auth.Login do
  @moduledoc """
  Custom login module that checks if the user is confirmed before
  allowing the user to log in.
  """

  use Phauxth.Login.Base

  alias Embers.Accounts
  alias Phauxth.Remember
  alias Embers.Sessions

  import EmbersWeb.Gettext

  @impl true
  def authenticate(%{"password" => password} = params, _user_context, opts) do
    case Accounts.get_by(params) do
      nil ->
        {:error, gettext("invalid credentials")}

      %{confirmed_at: nil} ->
        {:error, gettext("account unconfirmed")}

      user ->
        if Embers.Moderation.banned?(user) do
          ban = Embers.Moderation.get_active_ban(user.id)

          if Embers.Moderation.ban_expired?(ban) do
            Embers.Moderation.unban_user(user.id)
            Pbkdf2.check_pass(user, password, opts)
          else
            formatted_duration =
              if is_nil(ban.expires_at) do
                "indefinidamente"
              else
                formatted_date = Timex.format!(ban.expires_at, "{D}/{0M}/{YYYY}")
                "hasta el #{formatted_date}"
              end

            {:error,
             "Tu cuenta se encuentra baneada #{formatted_duration} con el motivo: #{ban.reason}"}
          end
        else
          Pbkdf2.check_pass(user, password, opts)
        end
    end
  end

  @impl true
  def report({:ok, user}, meta) do
    Log.info(%Log{user: user.id, message: "successful login", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end

  def report({:error, message}, meta) do
    Log.warn(%Log{message: message, meta: meta})
    {:error, message}
  end

  def add_session(conn, user, params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:session__id, session_id)
    |> configure_session(renew: true)
    |> add_remember_me(user.id, params)
  end

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Remember.add_rem_cookie(conn, user_id)
  end

  defp add_remember_me(conn, _, _), do: conn
end
