defmodule EmbersWeb.MetaController do
  use EmbersWeb, :controller

  alias Embers.Profile
  alias Embers.Profile.Meta

  action_fallback(EmbersWeb.FallbackController)

  def show(conn, %{"id" => id}) do
    meta = Profile.get_meta!(id)
    render(conn, "show.json", meta: meta)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    meta = Profile.get_meta!(user.id)

    with {:ok, %Meta{} = meta} <- Profile.update_meta(meta, params) do
      render(conn, "show.json", meta: meta)
    end
  end

  def upload_avatar(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"avatar" => file}) do
    meta = Profile.get_meta!(user.id)

    with :ok <- Embers.Profile.Uploads.Avatar.upload(file, user) do
      {:ok, meta} =
        meta
        |> Ecto.Changeset.change(avatar_version: DateTime.utc_now() |> DateTime.to_unix |> Integer.to_string())
        |> Embers.Repo.update()

      meta =
        meta
        |> Meta.load_avatar_map()
        |> Meta.load_cover()

      render(conn, "avatar.json", avatar: meta.avatar)
    end
  end

  def upload_cover(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"cover" => file}) do
    meta = Profile.get_meta!(user.id)

    with :ok <- Embers.Profile.Uploads.Cover.upload(file, user) do
      {:ok, meta} =
        meta
        |> Ecto.Changeset.change(cover_version: Integer.to_string(:os.system_time(:seconds)))
        |> Embers.Repo.update()

      meta = meta |> Meta.load_cover()

      render(conn, "cover.json", cover: meta.cover)
    end
  end
end