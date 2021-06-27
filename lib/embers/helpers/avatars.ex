defmodule Embers.Helpers.Avatars do
  def load_avatars(%Embers.Paginator.Page{} = page) do
    Map.update!(page, :entries, &load_avatars/1)
  end

  def load_avatars(entities) when is_list(entities) do
    Enum.map(entities, fn %{user: _user} = entity ->
      update_in(entity.user.meta, &Embers.Profile.Meta.load_avatar_map/1)
    end)
  end
end
