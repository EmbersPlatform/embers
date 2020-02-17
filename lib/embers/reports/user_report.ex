defmodule Embers.Reports.UserReport do
  @moduledoc false
  use Ecto.Schema

  alias Embers.Accounts.User

  import Ecto.Changeset

  schema "user_reports" do
    belongs_to(:user, User)
    belongs_to(:reporter, User)

    field(:comments, :string)
    field(:resolved, :boolean)

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:user_id, :reporter_id, :comments])
    |> validate_required([:reporter_id, :user_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:reporter_id)
  end
end

defimpl Embers.Reports.Reportable, for: Embers.Accounts.User do
  alias Embers.Reports.UserReport
  import Ecto.Query, only: [from: 2]

  def report(user, reporter, params \\ []) do
    comments = Keyword.get(params, :comments, "")

    report =
      UserReport.changeset(%UserReport{}, %{
        user_id: user.id,
        reporter_id: reporter.id,
        comments: comments
      })

    case Embers.Repo.insert(report) do
      {:ok, report} -> {:ok, report}
      error -> error
    end
  end

  def reports_for(user, opts \\ []) do
    resolved = Keyword.get(opts, :resolved, false)

    query =
      from(report in UserReport,
        where: report.user_id == ^user.id,
        where: report.resolved == ^resolved
      )

    Embers.Repo.all(query)
  end
end

defimpl Embers.Reports.Report, for: Embers.Reports.UserReport do
  def resolve(report) do
    report
    |> Ecto.Changeset.change(resolved: true)
    |> Embers.Repo.update()
  end

  def open(report) do
    report
    |> Ecto.Changeset.change(resolved: false)
    |> Embers.Repo.update()
  end
end
