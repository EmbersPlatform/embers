# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#
defmodule Seed do
  import Ecto.Query
  alias Embers.Repo

  def roles() do
    admin_permissions = ["any"]
    member_permissions = ~w(create_post create_media)

    moderator_permissions =
      ~w(access_backoffice access_mod_tools access_reports_queue ban_request warn_request ban_user update_user delete_post update_post delete_media update_media)

    roles = [
      %{name: "admin", permissions: admin_permissions},
      %{name: "member", permissions: member_permissions},
      %{name: "moderator", permissions: moderator_permissions}
    ]

    rolenames = Enum.map(roles, & &1.name)

    unless Repo.exists?(
             from(r in Embers.Authorization.Role, where: r.name in ^rolenames, select: r.id)
           ) do
      roles
      |> Enum.each(fn role ->
        Embers.Authorization.Roles.create(role.name, role.permissions)
      end)
    end
  end

  def admin_account() do
    unless Repo.exists?(
             from(u in Embers.Accounts.User, where: u.canonical == ^"admin", select: u.id)
           ) do
      {:ok, user} =
        Embers.Accounts.create_user(%{
          username: "admin",
          email: "admin@example.org",
          password: "yayapapaya"
        })

      Embers.Accounts.confirm_user(user)
      Embers.Authorization.Roles.attach_role(1, 1)
    end
  end

  def settings() do
    settings = [
      %{name: "rules", string_value: "Reglas del sitio"},
      %{name: "faq", string_value: "FAQ"},
      %{name: "acknowledgments", string_value: "Agradecimientos"}
    ]

    setting_names = Enum.map(settings, & &1.name)

    unless Repo.exists?(
             from(s in Embers.Settings.Setting, where: s.name in ^setting_names, select: s.id)
           ) do
      Enum.each(settings, fn attrs -> Embers.Settings.create(attrs) end)
    end
  end

  def domains_blacklist() do
    current_datetime = DateTime.utc_now()

    domains =
      Application.app_dir(:embers, "priv")
      |> Path.join("disposable_emails.txt")
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&match?("", &1))
      |> Enum.uniq()
      |> Enum.map(fn domain ->
        %{
          domain: domain,
          inserted_at: current_datetime,
          updated_at: current_datetime
        }
      end)
      |> Enum.chunk_every(10000)
      |> Enum.each(fn d ->
        Repo.insert_all("domains_blacklist", d, on_conflict: :nothing)
      end)
  end
end

Seed.roles()
Seed.admin_account()
Seed.settings()
Seed.domains_blacklist()
