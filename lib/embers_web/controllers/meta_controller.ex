defmodule EmbersWeb.MetaController do
  use EmbersWeb, :controller

  alias Embers.Profile
  alias Embers.Profile.Meta

  action_fallback(EmbersWeb.FallbackController)

  def show(conn, %{"id" => id}) do
    meta = Profile.get_meta!(id)
    render(conn, "show.json", meta: meta)
  end

  def update(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, %{"meta" => meta_params}) do
    meta = Profile.get_meta!(user_id)

    with {:ok, %Meta{} = meta} <- Profile.update_meta(meta, meta_params) do
      render(conn, "show.json", meta: meta)
    end
  end

  def upload_avatar(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"avatar" => file}) do
    meta = Profile.get_meta!(user.id)

    with {:ok, _} <- Embers.Profile.Uploads.Avatar.store({file, user}) do
      {:ok, meta} =
        meta
        |> Ecto.Changeset.change(avatar_name: Integer.to_string(:os.system_time(:seconds)))
        |> Embers.Repo.update()

      meta = meta |> Meta.load_avatar_map()

      render(conn, "avatar.json", avatar: meta.avatar)
    end
  end
end
