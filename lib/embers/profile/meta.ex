defmodule Embers.Profile.Meta do
  use Ecto.Schema
  import Ecto.Changeset

  alias Embers.Profile.Meta

  schema "user_metas" do
    field(:avatar_name, :string)
    field(:avatar, :map, virtual: true)
    field(:bio, :string)
    field(:cover_name, :string)
    belongs_to(:user, Embers.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(meta, attrs) do
    meta
    |> cast(attrs, [:user_id, :bio, :avatar, :avatar_name, :cover_name])
    |> validate_required([:user_id])
  end

  def load_avatar_map(%Meta{avatar_name: nil} = meta) do
    avatar_map = %{
      small: "/images/default_avatar.jpg",
      medium: "/images/default_avatar.jpg",
      big: "/images/default_avatar.jpg"
    }

    %{meta | avatar: avatar_map}
  end

  def load_avatar_map(%Meta{avatar_name: version} = meta) do
    avatar_map = %{
      small: gen_avatar_url(meta.user_id, "small", version),
      medium: gen_avatar_url(meta.user_id, "medium", version),
      big: gen_avatar_url(meta.user_id, "large", version)
    }

    %{meta | avatar: avatar_map}
  end

  defp gen_avatar_url(avatar, size, version) do
    gen_avatar_url(avatar, size) <> "?#{version}"
  end

  defp gen_avatar_url(avatar, size) do
    "/avatar/#{avatar}_#{size}.png"
  end
end
