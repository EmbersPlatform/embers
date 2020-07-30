defmodule Embers.Profile.Meta do
  @moduledoc """
  `Meta`s are additional profile info, such as description and avatar.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Embers.Helpers.IdHasher
  alias Embers.Profile.Meta

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
    |> validate_length(:bio, max: 255)
  end

  def update_cover_changeset(meta) do
    meta
    |> Ecto.Changeset.change(cover_version: Integer.to_string(:os.system_time(:seconds)))
  end

  def update_avatar_changeset(meta) do
    meta
    |> Ecto.Changeset.change(
      avatar_version: DateTime.utc_now() |> DateTime.to_unix() |> Integer.to_string()
    )
  end

  def avatar_map(%Meta{avatar_version: nil} = _meta) do
    %{
      small: "/images/default_avatar.jpg",
      medium: "/images/default_avatar.jpg",
      big: "/images/default_avatar.jpg"
    }
  end

  def avatar_map(%Meta{avatar_version: "legacy:" <> version} = _meta) do
    %{
      small: "/legacy/avatar/#{version}",
      medium: "/legacy/avatar/#{version}",
      big: "/legacy/avatar/#{version}"
    }
  end

  def avatar_map(%Meta{avatar_version: version} = meta) do
    id_hash = IdHasher.encode(meta.user_id)

    path =
      Application.get_env(:embers, Embers.Profile)
      |> Keyword.get(:avatar_path, "user/avatar")

    base = get_base()

    %{
      small: Path.join([base, path, "#{id_hash}_small.png?#{version}"]),
      medium: Path.join([base, path, "#{id_hash}_medium.png?#{version}"]),
      big: Path.join([base, path, "#{id_hash}_large.png?#{version}"])
    }
  end

  def cover(%Meta{cover_version: nil} = _meta) do
    "/images/default_cover.jpg"
  end

  def cover(%Meta{cover_version: "legacy:" <> version} = _meta) do
    "/legacy/cover/#{version}"
  end

  def cover(%Meta{cover_version: version} = meta) do
    id_hash = IdHasher.encode(meta.user_id)

    path =
      Application.get_env(:embers, Embers.Profile)
      |> Keyword.get(:cover_path, "user/avatar")

    base = get_base()

    Path.join([base, path, id_hash <> ".jpg?#{version}"])
  end

  def load_avatar_map(%Meta{} = meta) do
    %{meta | avatar: avatar_map(meta)}
  end

  def load_cover(%Meta{} = meta) do
    %{meta | cover: cover(meta)}
  end

  def populate(%Meta{} = meta) do
    meta
    |> load_cover()
    |> load_avatar_map()
  end

  defp get_base() do
    Embers.Uploads.base_path()
  end
end
