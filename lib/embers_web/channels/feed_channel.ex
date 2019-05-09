defmodule EmbersWeb.FeedChannel do
  @moduledoc false
  use Phoenix.Channel

  alias Embers.Helpers.IdHasher

  def join("feed:" <> id, _params, socket) do
    case check_user(id, socket) do
      true ->
        {:ok, socket}

      false ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  defp check_user(id, socket) do
    %Phoenix.Socket{assigns: %{user: user}} = socket
    IdHasher.decode(id) == user.id
  end
end
