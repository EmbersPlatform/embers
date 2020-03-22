defmodule EmbersWeb.ViewHelpers do
  use Phoenix.HTML

  alias Embers.Helpers.IdHasher

  def encode_id(nil), do: nil

  def encode_id(id) when is_integer(id) do
    IdHasher.encode(id)
  end

  def encode_id(id) when is_binary(id), do: id

  def labeled_link(opts, do: contents) when is_list(opts) do
    labeled_link(contents, opts)
  end

  def labeled_link(contents, opts) do
    {label, opts} = Keyword.pop_first(opts, :label)
    labels = ["aria-label": label, title: label]
    opts = Keyword.merge(labels, opts)
    link(contents, opts)
  end

  def labeled_link(opts) when is_list(opts) do
    contents = Keyword.pop_first(opts, :do)
    labeled_link(contents, opts)
  end

  def time_ago(date) do
    locale =
      Application.get_env(:embers, EmbersWeb.Gettext)
      |> Keyword.get(:default_locale, "en")

    Timex.from_now(date, locale)
  end
end
