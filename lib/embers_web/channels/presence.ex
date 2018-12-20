defmodule EmbersWeb.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :embers,
    pubsub_server: Embers.PubSub
end
