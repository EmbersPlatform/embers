defmodule Embers.Stats.Accounts do
  import Ecto.Query

  alias Embers.Accounts.User
  alias Embers.Repo

  def get_last_registered_users() do
    from(user in User,
      order_by: [desc: user.inserted_at],
      limit: 10,
      preload: [:meta]
    )
    |> Repo.all()
    |> Enum.map(fn user ->
      update_in(user.meta, &Embers.Profile.Meta.load_avatar_map/1)
    end)
  end
end
