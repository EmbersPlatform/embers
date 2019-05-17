defmodule Embers.Moderation do
  # TODO documentar
  alias Embers.Accounts.User
  alias Embers.Moderation.Ban

  alias Embers.Repo
  import Ecto.Query, only: [from: 2]

  def banned?(nil), do: false

  def banned?(%User{} = user) do
    banned?(user.id)
  end

  def banned?(user_id) when is_integer(user_id) do
    not is_nil(get_active_ban(user_id))
  end

  def get_active_ban(user_id) when is_integer(user_id) do
    Repo.one(bans_query(user_id))
  end

  def get_active_ban(%User{} = user) do
    get_active_ban(user.id)
  end

  def list_bans(user, opts \\ [])

  def list_bans(user_id, opts) when is_integer(user_id) do
    user_id
    |> bans_query(opts)
    |> Repo.all()
  end

  def list_bans(%User{} = user, opts) do
    list_bans(user.id, opts)
  end

  def ban_user(user, opts \\ [])

  def ban_user(user_id, opts) when is_integer(user_id) do
    if is_nil(get_active_ban(user_id)) do
      duration = Keyword.get(opts, :duration)
      expires = Timex.shift(DateTime.utc_now(), days: duration)

      Repo.insert(
        Ban.changeset(%Ban{}, %{
          user_id: user_id,
          reason: Keyword.get(opts, :reason),
          expires_at: expires
        })
      )
    else
      {:error, :already_banned}
    end
  end

  def ban_user(%User{} = user, opts) do
    ban_user(user.id, opts)
  end

  def unban_user(user_id) when is_integer(user_id) do
    case get_active_ban(user_id) do
      nil -> {:ok, nil}
      ban -> soft_delete(ban)
    end
  end

  def unban_user(%User{} = user) do
    unban_user(user.id)
  end

  defp soft_delete(%Ban{} = ban) do
    current_datetime = DateTime.utc_now() |> DateTime.truncate(:second)

    Repo.update(Ecto.Changeset.change(ban, %{deleted_at: current_datetime}))
  end

  defp bans_query(user_id, opts \\ []) do
    query =
      from(ban in Ban,
        where: ban.user_id == ^user_id
      )

    load_deleted? = Keyword.get(opts, :deleted, false)

    query =
      if not load_deleted? do
        from(ban in query, where: is_nil(ban.deleted_at))
      end || query

    query
  end
end
