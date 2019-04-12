defmodule EmbersWeb.Admin.LoadingMsgController do
  use EmbersWeb, :controller

  alias Embers.LoadingMsg
  alias Embers.LoadingMsg.Msg

  import EmbersWeb.Helpers

  plug(:put_layout, "dashboard.html")

  def index(conn, _params) do
    messages = LoadingMsg.list_all()

    render(conn, "list.html", messages: messages)
  end

  def new(conn, _params) do
    changeset = Msg.changeset(%Msg{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"msg" => msg_params}) do
    with {:ok, _msg} <- LoadingMsg.create(msg_params) do
      success(conn, "Mensaje creado con exito", loading_msg_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    msg = LoadingMsg.get(String.to_integer(id))
    changeset = Msg.changeset(msg, %{})

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "msg" => msg_params}) do
    msg = LoadingMsg.get(String.to_integer(id))

    with {:ok, _msg} <- LoadingMsg.update(msg, msg_params) do
      success(conn, "Mensaje actualizado con exito", loading_msg_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    with {:ok, _msg} <- LoadingMsg.remove(id) do
      success(conn, "Mensaje eliminado con exito", loading_msg_path(conn, :index))
    end
  end
end
