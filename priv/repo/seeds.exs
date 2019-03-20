# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

admin_permissions = ["any"]
member_permissions = ~w(create_post create_media)
janitor_permissions = ~w(access_reports_queue ban_request warn_request)

moderator_permissions =
  ~w(access_mod_tools access_reports_queue ban_request warn_request ban_user update_user delete_post update_post delete_media update_media)

roles = [
  %{name: "admin", permissions: admin_permissions},
  %{name: "member", permissions: member_permissions},
  %{name: "moderator", permissions: moderator_permissions},
  %{name: "janitor", permissions: janitor_permissions}
]

roles
|> Enum.each(fn role ->
  Embers.Authorization.Roles.create(role.name, role.permissions)
end)

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
