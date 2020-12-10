defmodule EmbersWeb.Web.Moderation.PostController do
  @moduledoc false

  use EmbersWeb, :controller

  action_fallback(EmbersWeb.Web.FallbackController)
end
