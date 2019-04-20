defmodule Embers.Reports do
  alias Embers.Repo
  alias Embers.Feed.Post
  alias Embers.Reports.Report

  @reportables [Post]

  def list_reports(%r{} = reportable) when r in @reportables do
    reportable
    |> Ecto.assoc(:reports)
    |> Repo.all()
  end

  def create_report(%r{} = reportable, attrs) when r in @reportables do
    reportable
    |> Ecto.build_assoc(:reports, attrs)
    |> Repo.insert()
  end

  def resolve(%Report{} = report) do
    report
    |> Ecto.Changeset.change(resolved: true)
    |> Repo.update()
  end

  def open(%Report{} = report) do
    report
    |> Ecto.Changeset.change(resolved: false)
    |> Repo.update()
  end
end
