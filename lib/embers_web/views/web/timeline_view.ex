defmodule EmbersWeb.Web.TimelineView do
  @moduledoc false
  use EmbersWeb, :view

  def render("timeline.json", page) do
    IO.inspect(page)

    %{
      activities: render_many(page.entries, __MODULE__, "activity.html"),
      last_page: page.last_page,
      next: page.next
    }
  end
end
