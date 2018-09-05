defmodule EmbersWeb.MetaController do
  use EmbersWeb, :controller

  alias Embers.Profile
  alias Embers.Profile.Meta

  action_fallback EmbersWeb.FallbackController

  def show(conn, %{"id" => id}) do
    meta = Profile.get_meta!(id)
    render(conn, "show.json", meta: meta)
  end

  def update(conn, %{"id" => id, "meta" => meta_params}) do
    meta = Profile.get_meta!(id)

    with {:ok, %Meta{} = meta} <- Profile.update_meta(meta, meta_params) do
      render(conn, "show.json", meta: meta)
    end
  end
end
