defmodule EmbersWeb.Presence do
  use Phoenix.Presence,
    otp_app: :embers,
    pubsub_server: Embers.PubSub

  import Ecto.Query

  alias Embers.{Repo, Accounts.User}
end
