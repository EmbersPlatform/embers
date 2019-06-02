defmodule Mix.Tasks.Embers.ConvertDb do
  @moduledoc false
  use Mix.Task

  alias Embers.Helpers.OldDbConverter, as: Converter

  @shortdoc "Convierte la antigua db"
  def run([path]) do
    Mix.EctoSQL.ensure_started(Embers.Repo, [])
    Converter.convert_users("#{path}users.json")
    Converter.convert_user_metas("#{path}user_metas.json")
    Converter.convert_posts("#{path}posts.json")
    Converter.convert_comments("#{path}comments.json")
    Converter.convert_reactions("#{path}reactions.json")
    Converter.convert_favorites("#{path}favorites.json")
    Converter.convert_follows("#{path}follows.json")
    Converter.convert_tags("#{path}tags.json")
    Converter.convert_tag_post("#{path}tag_post.json")
  end
end
