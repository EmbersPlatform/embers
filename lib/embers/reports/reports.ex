defmodule Embers.Reports do
  @moduledoc """
  Tambien conocidos como denuncias, los reportes se generan cuando un
  usuario quiere dar aviso al staff de contenido que infringe las reglas
  del sitio.

  Ejemplos de reportables son los Posts.
  """

  alias Embers.Feed.Post
  alias Embers.Repo
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
