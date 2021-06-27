defmodule Mix.Tasks.Embers.Static do
  @moduledoc false
  use Mix.Task

  @shortdoc "Copies the contents in /assets/static to /priv/static"
  def run(_) do
    File.cp_r("./assets/static", "./priv/static")
  end
end
