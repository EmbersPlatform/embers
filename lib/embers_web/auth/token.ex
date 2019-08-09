defmodule EmbersWeb.Auth.Token do
  @moduledoc """
  Custom token implementation using Phauxth.Token behaviour and Phoenix Token.
  """

  @behaviour Phauxth.Token

  alias Phoenix.Token
  alias EmbersWeb.Endpoint

  # 7 days
  @max_age 7 * 24 * 60 * 60
  @token_salt Application.get_env(:embers, :auth) |> Keyword.get(:token_salt)

  @impl true
  def sign(data, opts \\ []) do
    Token.sign(Endpoint, @token_salt, data, opts)
  end

  @impl true
  def verify(token, opts \\ []) do
    max_age = Keyword.get(opts, :max_age, @max_age)
    Token.verify(Endpoint, @token_salt, token, opts ++ [max_age: max_age])
  end
end
