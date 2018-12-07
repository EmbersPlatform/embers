defmodule EmbersWeb.Presence do
  use Phoenix.Presence,
    otp_app: :embers,
    pubsub_server: Embers.PubSub
end
