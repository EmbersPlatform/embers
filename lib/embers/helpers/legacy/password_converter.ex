defmodule Embers.Helpers.PasswordConverter do
  @moduledoc false

  def convert(password) do
    parts = String.split(password, ":")

    data =
      Enum.at(parts, 1)
      |> format_base64
      |> Pbkdf2.Base64.decode()
      |> Jason.decode!()

    digest = data["algo"]
    rounds = data["rounds"]
    salt = data["salt"] |> format_base64
    hash = data["hash"] |> format_base64

    "$pbkdf2-#{digest}$#{rounds}$#{salt}$#{hash}"
  end

  defp format_base64(string) do
    string
    |> String.replace("+", ".")
    |> String.replace("=", "")
  end
end
