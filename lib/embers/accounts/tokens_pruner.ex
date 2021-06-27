defmodule Embers.Accounts.TokensPruner do
  use Oban.Worker, queue: :default

  alias Embers.Accounts.UserToken
  alias Embers.Repo

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Enum.each(~w[session reset_password confirm], fn context ->
      UserToken.expired_tokens_by_context_query(context)
      |> Repo.delete_all()
    end)

    UserToken.expired_change_email_tokens_query()
    |> Repo.delete_all()

    :ok
  end
end
