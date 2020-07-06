defmodule Embers.Accounts.DisposableEmail do
  @moduledoc """
  Contains list of providers of disposable email address.
  """

  @behaviour EmailGuard.List

  @impl EmailGuard.List

  @filepath Application.app_dir(:embers, "priv")
            |> Path.join("disposable_emails.txt")

  @filepath
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.reject(&match?("", &1))
  |> Enum.uniq()
  |> Enum.map(fn domain ->
    def lookup(unquote(domain)), do: __MODULE__
  end)

  def lookup(_unmatched_domain), do: nil
end
