defmodule Embers.Reports.Report do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "abstract table:reports" do
    field(:assoc_id, :integer)
    belongs_to(:reporter, Embers.Accounts.User)

    field(:comments, :string)
    field(:resolved, :boolean)

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:reporter_id, :comments])
    |> foreign_key_constraint(:assoc_id)
    |> validate_required([:reported_id, :post_id])
  end
end
