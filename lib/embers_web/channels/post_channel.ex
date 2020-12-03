defmodule EmbersWeb.PostChannel do
  @moduledoc false
  use Phoenix.Channel

  intercept(["reactions_updated"])

  def join("post:" <> _id, _params, socket) do
    {:ok, socket}
  end

  defp check_user(id, socket) do
    %Phoenix.Socket{assigns: %{user: user}} = socket
    id == user.id
  end

  def handle_out("reactions_updated", payload, %{assigns: %{user: nil}} = socket) do
    push(socket, "reactions_updated", Map.drop(payload, [:user_id]))
    {:noreply, socket}
  end

  def handle_out("reactions_updated", %{user_id: user_id} = payload, socket) do
    unless user_id == socket.assigns.user.id do
      push(socket, "reactions_updated", Map.drop(payload, [:user_id]))
    end

    {:noreply, socket}
  end
end
