defmodule Embers.Accounts.DisposableEmail do
  import Ecto.Query

  alias Embers.Repo

  def disposable?(email) do
    domain = extract_domain(email)

    from(
      d in "domains_blacklist",
      where: d.domain == ^domain
    )
    |> Repo.exists?
  end

  defp extract_domain(input) do
    input
    |> :binary.split("@", [:global])
    |> List.last()
  end
end
