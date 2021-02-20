defmodule EmbersWeb.Moderation.PostController do
  @moduledoc false

  use EmbersWeb, :controller

  action_fallback(EmbersWeb.FallbackController)
end
