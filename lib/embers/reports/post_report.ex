defmodule Embers.Reports.PostReport do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Embers.Accounts.User
  alias Embers.Posts.Post
  alias Embers.Repo
  alias Embers.Reports.Queries

  @primary_key {:id, Embers.Hashid, autogenerate: true}
  schema "post_reports" do
    belongs_to(:post, Post, type: Embers.Hashid)
    belongs_to(:reporter, User, type: Embers.Hashid)

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
    preloads = Keyword.get(opts, :preload)
    pagination_opts = Keyword.get(opts, :pagination, [])
    from(r in __MODULE__,
      distinct: r.post_id,
      where: r.resolved == false,
      left_join: post in assoc(r, :post),
      where: is_nil(post.deleted_at),
      order_by: [desc: r.inserted_at],
      preload: [
        post: [
          :media,
          :links,
          :tags,
          :reactions,
          user: [:meta],
          related_to: [:media, :tags, :links, :reactions, user: :meta]
        ]
      ]
    )
    |> Embers.Paginator.paginate(pagination_opts)
  end
end

defimpl Embers.Reports.Reportable, for: Embers.Posts.Post do
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

defimpl Embers.Reports.Report, for: Embers.Reports.PostReport do
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
