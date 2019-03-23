defmodule Mix.Tasks.Embers.Static do
  use Mix.Task

  @shortdoc "Copies the contents in /assets/static to /priv/static"

  def run(_args) do
    File.cp_r("./assets/static", "./priv/static")
  end
end
