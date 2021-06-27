defmodule Embers.LoadingMsg.Msg do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "loading_msg" do
    field(:name, :string)
    field(:title, :string)
    field(:subtitle, :string)
    field(:url, :string)
    field(:background, :boolean, default: false)
    field(:color, :string)
    field(:styles, :string)
    field(:active, :boolean, defalt: true)
  end

  def changeset(msg, attrs) do
    msg
    |> cast(attrs, ~w(name title subtitle url background color styles active)a)
    |> unique_constraint(:name)
  end
end
