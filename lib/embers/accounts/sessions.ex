defmodule Embers.Accounts.Sessions do
  alias Embers.Accounts.User
  alias Embers.Accounts.UserToken
  alias Embers.Repo

  @doc """
  Returns a list with all the session tokens associated with the given user
  """
  def list_sessions(user = %User{}) do
    query =
      UserToken.token_by_user_and_context_query(user.id, "session")
      |> UserToken.active_token_query()

    Repo.all(query)
  end
end
