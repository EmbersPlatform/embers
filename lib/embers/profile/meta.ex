defmodule Embers.Profile.Meta do
  use Ecto.Schema
  import Ecto.Changeset

  alias Embers.Profile.Meta

  schema "user_metas" do
    field :avatar_name, :string
    field :avatar, :map, virtual: true
    field :bio, :string
    field :cover_name, :string
    belongs_to :user, Embers.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(meta, attrs) do
    meta
    |> cast(attrs, [:user_id, :bio, :avatar, :avatar_name, :cover_name])
    |> validate_required([:user_id])
  end

  def load_avatar_map(%Meta{avatar_name: nil} = meta) do
    avatar_map =
      %{
        small: gen_avatar_url("default", 128),
        medium: gen_avatar_url("default", 250),
        big: gen_avatar_url("default", 512)
      }

    %{meta | avatar: avatar_map}
  end

  def load_avatar_map(%Meta{avatar_name: avatar} = meta) do
    avatar_map =
      %{
        small: gen_avatar_url(avatar, 128),
        medium: gen_avatar_url(avatar, 250),
        big: gen_avatar_url(avatar, 512)
      }

    %{meta | avatar: avatar_map}
  end

  defp gen_avatar_url(avatar, size) when is_binary(avatar) and is_integer(size) do
    size = to_string(size)
    url = "/avatar/"<>avatar<>"@"<>size<>".jpg"
    url
  end
end
