defmodule Embers.Feed.Reactions do
  @moduledoc """
  Las reacciones representan la emoción que un contenido provocó
  en un usuario. Un usuario puede reaccionar a un contenido más de una vez,
  siempre y cuando sea con distintas reacciones.
  """
  alias Embers.Feed.Reactions.Reaction
  alias Embers.Paginator
  alias Embers.Profile.Settings.Setting
  alias Embers.Repo

  import Ecto.Query

  def create_reaction(attrs) do
    reaction_changeset = Reaction.create_changeset(%Reaction{}, attrs)

    Repo.insert(reaction_changeset)
  end

  def create_reaction!(attrs) do
    case create_reaction(attrs) do
      {:ok, reaction} -> reaction
      {:error, changeset} -> changeset
    end
  end

  def delete_reaction(nil), do: nil

  def delete_reaction(id) when is_integer(id) do
    reaction =
      Repo.one!(
        from(
          reaction in Reaction,
          where: reaction.id == ^id
        )
      )

    delete_reaction(reaction)
  end

  def delete_reaction(%{"name" => name, "user_id" => user_id, "post_id" => post_id}) do
    reaction =
      Repo.one(
        from(
          reaction in Reaction,
          where: reaction.name == ^name,
          where: reaction.user_id == ^user_id,
          where: reaction.post_id == ^post_id
        )
      )

    delete_reaction(reaction)
  end

  def delete_reaction(%Reaction{} = reaction) do
    Repo.delete(reaction)
  end

  def overview(post_id) do
    query =
      from(
        reaction in Reaction,
        where: reaction.post_id == ^post_id,
        group_by: reaction.name,
        select: %{name: reaction.name, count: count(reaction.name)}
      )

    Repo.all(query)
  end

  def who_reacted(post_id, opts \\ []) do
    reaction_name = Keyword.get(opts, :reaction)

    query =
      from(
        reaction in Reaction,
        where: reaction.post_id == ^post_id,
        preload: [user: :meta]
      )

    query =
      if not is_nil(reaction_name) do
        from(reaction in query,
          where: reaction.name == ^reaction_name
        )
      end || query

    page = Paginator.paginate(query, opts)

    user_ids =
      Enum.map(page.entries, fn r ->
        r.user.id
      end)

    private_users_ids =
      Repo.all(
        from(setting in Setting,
          where: setting.user_id in ^user_ids,
          where: setting.privacy_show_reactions == false,
          select: setting.user_id
        )
      )

    entries = Enum.reject(page.entries, fn r -> r.user.id in private_users_ids end)

    %{page | entries: entries}
  end
end
