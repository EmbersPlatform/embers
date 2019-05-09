defmodule Embers.Feed.Reactions do
  @moduledoc """
  Las reacciones representan la emoción que un contenido provocó
  en un usuario. Un usuario puede reaccionar a un contenido más de una vez,
  siempre y cuando sea con distintas reacciones.
  """
  alias Embers.Feed.Reactions.Reaction
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
end
