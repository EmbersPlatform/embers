defmodule Embers.Reports.PostReport do
  @moduledoc false
  use Ecto.Schema

  alias Embers.Accounts.User
  alias Embers.Feed.Post
  alias Embers.Paginator
  alias Embers.Repo

  import Ecto.Changeset
  import Ecto.Query

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
    |> validate_length(:comments, min: 4, max: 255)
  end

  def list_paginated(opts \\ []) do
    from(r in __MODULE__,
      where: r.resolved == false,
      left_join: post in assoc(r, :post),
      left_join: author in assoc(post, :user),
      group_by: [post.id, author.username],
      select: %{
        post: post,
        author: author.username,
        count: fragment("count(?) as count", r.id)
      },
      order_by: [desc: fragment("count")]
    )
    |> Repo.paginate(opts)
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
