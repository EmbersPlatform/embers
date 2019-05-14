defprotocol Embers.Reportable do
  @doc "Reporta a un reportable(ej: Post, User)"
  def report(reportable, reporter, params)

  def reports_for(reportable, opts \\ [])
end

defprotocol Embers.Report do
  @doc "Marca un reporte como resuelto"
  def resolve(report)

  def open(report)
end

defmodule Embers.Reports do
  @moduledoc """
  Tambien conocidos como denuncias, los reportes se generan cuando un
  usuario quiere dar aviso al staff de contenido que infringe las reglas
  del sitio.

  Ejemplos de reportables son los Posts.
  """
end
