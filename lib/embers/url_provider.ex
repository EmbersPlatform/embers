defmodule Embers.UrlProvider do
  @type url :: String.t()
  @type token :: String.t()

  @callback confirmation(token) :: url
  @callback password_reset(token) :: url
  @callback email_reset(token) :: url
end
