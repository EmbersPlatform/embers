# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

users = [
  %{username: "jane", email: "jane.doe@example.com", password: "yayapapaya"},
  %{username: "john", email: "john.smith@example.org", password: "yayapapaya"}
]

for user <- users do
  {:ok, user} = Embers.Accounts.create_user(user)
  Embers.Accounts.confirm_user(user)
end

Enum.each(1..50, fn x ->
  Embers.Feed.create_post(%{user_id: 1, body: Integer.to_string(x)})
end)
