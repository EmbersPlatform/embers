defmodule Embers.Profile.Meta do
  @moduledoc """
  Los Meta son la informacion adicional de los perfiles de los usuarios, como
  la descripcion del perfil y el avatar
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

  def avatar_map(%Meta{avatar_version: nil} = _meta) do
    %{
      small: "/images/default_avatar.jpg",
      medium: "/images/default_avatar.jpg",
      big: "/images/default_avatar.jpg"
    }
  end

  def avatar_map(%Meta{avatar_version: version} = meta) do
    id_hash = IdHasher.encode(meta.user_id)

    path =
      Application.get_env(:embers, Embers.Profile) |> Keyword.get(:avatar_path, "/user/avatar")

    base = get_base()

    %{
      small: "#{base}#{path}/#{id_hash}_small.png?#{version}",
      medium: "#{base}#{path}/#{id_hash}_medium.png?#{version}",
      big: "#{base}#{path}/#{id_hash}_large.png?#{version}"
    }
  end

  def cover(%Meta{cover_version: nil} = _meta) do
    "/images/default_cover.jpg"
  end

  def cover(%Meta{cover_version: version} = meta) do
    id_hash = IdHasher.encode(meta.user_id)

    path =
      Application.get_env(:embers, Embers.Profile) |> Keyword.get(:cover_path, "/user/avatar")

    base = get_base()

    "#{base}#{path}/#{id_hash}.jpg?#{version}"
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

  defp get_bucket() do
    Keyword.get(Application.get_env(:embers, Embers.Profile), :bucket, "local")
  end

  defp get_base() do
    case get_bucket() do
      "local" ->
        ""

      bucket ->
        %{
          scheme: scheme,
          region: region
        } = s3_config = Application.get_env(:ex_aws, :s3)

        host = s3_config.host[region]
        scheme <> host <> "/" <> bucket
    end
  end
end
