defmodule Embers.Search.Params do
  @moduledoc false
  @type t() :: %__MODULE__{
          original_query: String.t() | nil,
          term: String.t() | nil,
          tags: list() | nil,
          authors: list() | nil,
          media_types: list() | nil,
          nsfw: boolean(),
          sfw: boolean()
        }
  defstruct [
    :original_query,
    :term,
    :tags,
    :authors,
    :media_types,
    nsfw: false,
    sfw: false
  ]
end

defmodule Embers.Search do
  @moduledoc false
  alias Embers.Accounts.User
  alias Embers.Posts.Post
  alias Embers.Paginator
  alias Embers.Repo
  alias Embers.Search.Params

  import Ecto.Query

  @operators %{
    tag: ~r/(?<!["])(?:tag:|\#)(\pL(?:(?:[\pL\pN][\.\-_])?[\pL\pN]){1,30})(?!["])/,
    author: ~r/(?<!["])@(\pL(?:(?:[\pL\pN][\.\-_])?[\pL\pN]){0,19})(?!["])/,
    nsfw: ~r/(?<!["])-nsfw(?!["])/,
    sfw: ~r/(?<!["])-sfw(?!["])/,
    image: ~r/(?<!["])-i(?!["])/,
    video: ~r/(?<!["])-v(?!["])/,
    link: ~r/(?<!["])-l(?!["])/
  }

  @spec search(binary() | Embers.Search.Params.t(), keyword()) :: Embers.Paginator.Page.t()
  def search(what, opts \\ [])

  def search(%Params{} = params, opts) do
    exec(params, opts)
  end

  def search(query, opts) do
    query
    |> parse_query()
    |> exec(opts)
  end

  @spec parse_query(binary()) :: Embers.Search.Params.t()
  def parse_query(query) when is_binary(query) do
    tags = parse_tags(query)
    authors = parse_authors(query)
    nsfw = parse_nsfw(query)
    sfw = parse_sfw(query)
    search_term = clean_operators(query)
    media_types = parse_media_types(query)

    %Params{
      original_query: query,
      term: search_term,
      tags: tags,
      authors: authors,
      nsfw: nsfw,
      sfw: sfw,
      media_types: media_types
    }
  end

  def exec(%Params{} = params, opts) do
    posts_query =
      from(
        post in Post,
        where: is_nil(post.deleted_at),
        where: post.nesting_level == 0,
        where: is_nil(post.related_to_id),
        order_by: [desc: post.id],
        left_join: user in assoc(post, :user),
        left_join: meta in assoc(user, :meta),
        preload: [
          [:media, :reactions, :tags]
        ],
        preload: [
          user: {user, meta: meta}
        ]
      )

    posts_query
    |> maybe_search_by_term(params)
    |> maybe_search_by_tags(params)
    |> maybe_search_by_authors(params)
    |> maybe_search_by_media_type(params)
    |> Paginator.paginate(opts)
    |> fill_nsfw()
  end

  defp parse_tags(query) do
    @operators.tag
    |> Regex.scan(query, capture: :all_but_first)
    |> Enum.map(fn [tag] -> tag end)
    |> list_or_nil()
  end

  defp parse_authors(query) do
    @operators.author
    |> Regex.scan(query, capture: :all_but_first)
    |> Enum.map(fn [author] -> String.downcase(author) end)
    |> list_or_nil()
  end

  defp parse_nsfw(query) do
    Regex.match?(@operators.nsfw, query)
  end

  defp parse_sfw(query) do
    Regex.match?(@operators.sfw, query)
  end

  defp parse_media_types(query) do
    types = []

    types =
      if Regex.match?(@operators.image, query) do
        types ++ ["image"]
      end || types

    types =
      if Regex.match?(@operators.video, query) do
        types ++ ["video"]
      end || types

    types =
      if Regex.match?(@operators.link, query) do
        types ++ ["link"]
      end || types

    list_or_nil(types)
  end

  defp clean_operators(query) do
    @operators
    |> Enum.reduce(query, fn {_, operator}, acc ->
      Regex.replace(operator, acc, "")
    end)
    |> String.trim()
  end

  defp list_or_nil(term) do
    if Enum.empty?(term) do
      nil
    else
      term
    end
  end

  defp maybe_search_by_term(query, %Params{term: term}) when is_binary(term) do
    if String.length(term) > 0 do
      from(
        post in query,
        where: ilike(post.body, ^"%#{term}%")
      )
    end || query
  end

  defp maybe_search_by_term(query, _params), do: query

  defp maybe_search_by_authors(query, %Params{authors: authors}) when is_list(authors) do
    authors =
      Repo.all(
        from(
          user in User,
          where: user.canonical in ^authors,
          select: user.id
        )
      )

    from(post in query, where: post.user_id in ^authors)
  end

  defp maybe_search_by_authors(query, _params), do: query

  defp maybe_search_by_tags(query, %Params{tags: tags}) when is_list(tags) do
    tags = Enum.map(tags, &String.upcase/1)

    from(
      post in query,
      left_join: tags in assoc(post, :tags),
      where: fragment("upper(?)", tags.name) in ^tags
    )
  end

  defp maybe_search_by_tags(query, _params), do: query

  defp maybe_search_by_media_type(query, %Params{media_types: media_types})
       when is_list(media_types) do
    from(
      post in query,
      left_join: media in assoc(post, :media),
      where: media.type in ^media_types
    )
  end

  defp maybe_search_by_media_type(query, _params), do: query

  defp fill_nsfw(%Embers.Paginator.Page{} = page) do
    %{page | entries: Enum.map(page.entries, fn post -> Post.fill_nsfw(post) end)}
  end
end
