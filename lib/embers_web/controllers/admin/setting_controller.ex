defmodule EmbersWeb.Admin.SettingController do
  use EmbersWeb, :controller

  import EmbersWeb.Helpers

  alias Embers.Settings
  alias Embers.Settings.Setting

  plug(:put_layout, "dashboard.html")

  def index(conn, _params) do
    settings = Settings.list()
    render(conn, "list.html", settings: settings)
  end

  def edit(conn, %{"name" => name}) do
    setting = Settings.get!(name)
    changeset = Setting.changeset(setting, %{})
    render(conn, "edit.html", changeset: changeset, setting: setting)
  end

  def update(conn, %{"name" => name, "setting" => attrs}) do
    setting = Settings.get!(name)

    case Settings.update(name, attrs) do
      {:ok, _setting} ->
        success(conn, "Configuracion actualizada!", setting_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Hubo un error al actualizar la configuracion")
        |> render("edit.html", changeset: changeset, setting: setting)
    end
  end
end
