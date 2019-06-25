defmodule Mix.Tasks.Embers.ConvertDb do
  @moduledoc false
  use Mix.Task

  alias Embers.Helpers.OldDbConverter, as: Converter

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql,
    :not_qwerty123
  ]

  @shortdoc "Convierte la antigua db"
  def run([path]) do
    :ok = Application.load(:embers)
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    Embers.Repo.start_link(pool_size: 2)

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
