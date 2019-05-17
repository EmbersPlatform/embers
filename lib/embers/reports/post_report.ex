defmodule Embers.Reports.PostReport do
  @moduledoc false
  use Ecto.Schema

  alias Embers.Accounts.User
  alias Embers.Feed.Post

  import Ecto.Changeset

  schema "post_reports" do
    belongs_to(:post, Post)
    belongs_to(:reporter, User)

    field(:comments, :string)
    field(:resolved, :boolean)

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:post_id, :reporter_id, :comments])
    |> validate_required([:reporter_id, :post_id])
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:reporter_id)
  end
end

defimpl Embers.Reportable, for: Embers.Feed.Post do
  alias Embers.Reports.PostReport
  import Ecto.Query, only: [from: 2]

  def report(post, reporter, params \\ []) do
    comments = Keyword.get(params, :comments, "")

    report =
      PostReport.changeset(%PostReport{}, %{
        post_id: post.id,
        reporter_id: reporter.id,
        comments: comments
      })

    case Embers.Repo.insert(report) do
      {:ok, report} -> {:ok, report}
      error -> error
    end
  end

  def reports_for(post, opts \\ []) do
    resolved = Keyword.get(opts, :resolved, false)

    query =
      from(report in PostReport,
        where: report.post_id == ^post.id,
        where: report.resolved == ^resolved
      )

    Embers.Repo.all(query)
  end
end

defimpl Embers.Report, for: Embers.Reports.PostReport do
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
