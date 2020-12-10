defmodule Embers.Reports.Queries do
  import Ecto.Query

  def with_post(query) do
    from(report in query,
      left_join: post in assoc(report, :post),
      preload: [post: post]
    )
  end
end
