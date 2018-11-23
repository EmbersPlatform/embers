defmodule EmbersWeb.Auth.Login do
  @moduledoc """
  Custom login module that checks if the user is confirmed before
  allowing the user to log in.
  """

  use Phauxth.Login.Base

  alias Comeonin.Pbkdf2
  alias Embers.Accounts

  @impl true
  def authenticate(%{"password" => password} = params, _, opts) do
    case Accounts.get_by(params) do
      nil -> {:error, "no user found"}
      %{confirmed_at: nil} -> {:error, "account unconfirmed"}
      user -> Pbkdf2.check_pass(user, password, opts)
    end
  end
end
