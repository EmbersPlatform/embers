defmodule EmbersWeb.ModChannel do
  use Phoenix.Channel

  alias Embers.Authorization

  def join("mod", _payload, socket) do
    if check_user(socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def check_user(socket) do
    user = socket.assigns.user
    Authorization.can?("access_mod_tools", user)
  end
end
