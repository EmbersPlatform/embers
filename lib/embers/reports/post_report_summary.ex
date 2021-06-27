defmodule Embers.Reports.PostReportSummary do
  @type t :: %__MODULE__{
          post: %Embers.Posts.Post{} | nil,
          count: integer() | nil,
          main_reason: String.t() | nil
        }
  defstruct [:post, :count, :main_reason]
end
