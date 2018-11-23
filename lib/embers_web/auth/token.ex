defmodule EmbersWeb.Auth.Token do
  @moduledoc """
  Custom token implementation using Phauxth.Token behaviour and Phoenix Token.
  """

  @behaviour Phauxth.Token

  alias Phoenix.Token
  alias EmbersWeb.Endpoint

  # 7 days
  @max_age 604_800
  @token_salt "JaKgaBf2"

  @impl true
  def sign(data, opts \\ []) do
    Token.sign(Endpoint, @token_salt, data, opts)
  end

  @impl true
  def verify(token, opts \\ []) do
    Token.verify(Endpoint, @token_salt, token, opts ++ [max_age: @max_age])
  end
end
