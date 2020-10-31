defmodule EmbersWeb.ViewHelpers do
  use Phoenix.HTML

  alias EmbersWeb.Router.Helpers

  def get_locale(conn) do
    Map.get(
      conn.assigns,
      :locale,
      Application.get_env(:embers, EmbersWeb.Gettext)[:default_locale]
    )
  end

  def authenticated?(%{assigns: %{current_user: user}}) when not is_nil(user), do: true
  def authenticated?(_), do: false

  def is_owner?(conn, resource) do
    user = conn.assigns.current_user

    not is_nil(user) and user.id == resource.user_id
  end

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

  def attr_list(attrs, joiner \\ " ") when is_list(attrs) do
    Enum.reduce(attrs, [], fn
      attr, acc when is_binary(attr) ->
        acc ++ [attr]

      {attr, true}, acc when is_binary(attr) ->
        acc ++ [attr]

      {attr, predicate}, acc when is_binary(attr) and is_function(predicate) ->
        if predicate.(), do: acc ++ [attr], else: acc

      fun, acc when is_function(fun) ->
        acc ++ [fun.()]

      _, acc ->
        acc
    end)
    |> Enum.join(joiner)
  end

  def decoded_path(helper, conn_or_endpoint, action, id, query_params \\ []) do
    apply(Helpers, helper, [conn_or_endpoint, action, id, query_params])
    |> URI.decode_www_form()
  end
end
