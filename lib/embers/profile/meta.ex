defmodule Embers.Profile.Meta do
  use Ecto.Schema
  import Ecto.Changeset

  alias Embers.Profile.Meta
  alias Embers.Helpers.IdHasher

  schema "user_metas" do
    field(:avatar_version, :string)
    field(:avatar, :map, virtual: true)
    field(:bio, :string)
    field(:cover_version, :string)
    field(:cover, :string, virtual: true)
    belongs_to(:user, Embers.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(meta, attrs) do
    meta
    |> cast(attrs, [:user_id, :bio, :avatar, :avatar_version, :cover_version])
    |> validate_required([:user_id])
  end

  def avatar_map(%Meta{avatar_version: nil} = _meta) do
    %{
      small: "/images/default_avatar.jpg",
      medium: "/images/default_avatar.jpg",
      big: "/images/default_avatar.jpg"
    }
  end

  def avatar_map(%Meta{avatar_version: version} = meta) do
    id_hash = IdHasher.encode(meta.user_id)

    %{
      small: "/avatar/#{id_hash}_small.png?#{version}",
      medium: "/avatar/#{id_hash}_medium.png?#{version}",
      big: "/avatar/#{id_hash}_large.png?#{version}"
    }
  end

  def cover(%Meta{cover_version: nil} = _meta) do
    "/images/default_cover.jpg"
  end

  def cover(%Meta{cover_version: version} = meta) do
    id_hash = IdHasher.encode(meta.user_id)
    "/cover/#{id_hash}.jpg?#{version}"
  end

  def load_avatar_map(%Meta{} = meta) do
    %{meta | avatar: avatar_map(meta)}
  end

  def load_cover(%Meta{} = meta) do
    %{meta | cover: cover(meta)}
  end
end
