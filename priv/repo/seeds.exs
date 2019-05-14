# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

admin_permissions = ["any"]
member_permissions = ~w(create_post create_media)

moderator_permissions =
  ~w(access_backoffice access_mod_tools access_reports_queue ban_request warn_request ban_user update_user delete_post update_post delete_media update_media)

roles = [
  %{name: "admin", permissions: admin_permissions},
  %{name: "member", permissions: member_permissions},
  %{name: "moderator", permissions: moderator_permissions}
]

roles
|> Enum.each(fn role ->
  Embers.Authorization.Roles.create(role.name, role.permissions)
end)

{:ok, user} =
  Embers.Accounts.create_user(%{
    username: "admin",
    email: "admin@example.org",
    password: "yayapapaya"
  })

Embers.Accounts.confirm_user(user)
Embers.Authorization.Roles.attach_role(1, 1)
