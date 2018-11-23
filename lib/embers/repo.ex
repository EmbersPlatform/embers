defmodule Embers.Repo do
  use Ecto.Repo, otp_app: :embers, adapter: Ecto.Adapters.Postgres
end
