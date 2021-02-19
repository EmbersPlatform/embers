defmodule EmbersWeb.Router do
  use EmbersWeb, :router

  import EmbersWeb.UserAuth

  import Phoenix.LiveDashboard.Router

  alias EmbersWeb.Plugs.{CheckPermissions, GetPermissions}

  # See https://github.com/elixir-cldr/cldr/issues/135#issuecomment-629119938
  require EmbersWeb.Cldr

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)

    plug(:fetch_live_flash)
    # plug(:put_root_layout, {EmbersWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    plug(:fetch_current_user)

    plug(Cldr.Plug.SetLocale,
      apps: [:cldr, :gettext],
      from: [:accept_language, :path, :query],
      gettext: EmbersWeb.Gettext,
      cldr: EmbersWeb.Cldr
    )

    plug(:put_locale_to_session)

    plug(GetPermissions)
    plug(EmbersWeb.Plugs.LoadSettings)
    plug(EmbersWeb.Plugs.SelectLayout)
    plug(EmbersWeb.Plugs.ModData)
  end

  pipeline :live_layout do
    plug(:put_root_layout, {EmbersWeb.LayoutView, :root})
    plug(:require_authenticated_user)
  end

  pipeline :admin do
    plug(:accepts, ["html"])
    plug(CheckPermissions, permission: "access_backoffice")
  end

  defp put_locale_to_session(conn, _opts) do
    locale = Cldr.get_locale().language

    conn
    |> put_session(:locale, locale)
  end

  scope "/" do
    pipe_through([:browser, :admin])

    live_dashboard("/dashboard", ecto_repos: [Embers.Repo], metrics: EmbersWeb.Telemetry)
  end

  ## Authentication routes

  scope "/", EmbersWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/register", UserRegistrationController, :new)
    post("/register", UserRegistrationController, :create)
    get("/login", UserSessionController, :new)
    post("/login", UserSessionController, :create)
    get("/reset_password", UserResetPasswordController, :new)
    post("/reset_password", UserResetPasswordController, :create)
    get("/reset_password/:token", UserResetPasswordController, :edit)
    put("/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", EmbersWeb do
    pipe_through([:browser, :require_authenticated_user])

    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings", UserSettingsController, :update)
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
  end

  scope "/", EmbersWeb do
    pipe_through([:browser])

    delete("/logout", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :confirm)
  end

  scope "/", EmbersWeb.Web do
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/static/rules", PageController, :rules)
    get("/static/faq", PageController, :faq)
    get("/static/acknowledgments", PageController, :acknowledgments)

    # Settings
    scope "/settings" do
      patch("/", SettingsController, :update)
      post("/reset_pass", SettingsController, :reset_pass)

      put("/account/update_password", SettingsController, :update_password)
      put("/account/update_email", SettingsController, :update_email)
      get("/account/confirm_email/:token", SettingsController, :confirm_email)

      patch("/profile/update_profile", SettingsController, :update_profile)
      post("/profile/update_cover", SettingsController, :update_cover)
      post("/profile/update_avatar", SettingsController, :update_avatar)

      # get("/security", SettingsController, :show_security)
    end

    scope "/settings" do
      pipe_through(:live_layout)

      get("/", SettingsController, :show_profile)
      get("/profile", SettingsController, :show_profile)
      get("/content", SettingsController, :show_content)
      get("/design", SettingsController, :show_design)
      live("/privacy", Settings.PrivacyLive.Index, :index)
      live("/security", Settings.SecurityLive.Index, :index)
    end

    # Feeds
    get("/timeline", TimelineController, :index)
    delete("/timeline/activity/:id", TimelineController, :hide_activity)
    get("/discover", DiscoverController, :index)

    # User profile
    get("/user/:user_id/timeline", UserController, :timeline)
    get("/@:username", UserController, :show)
    get("/@:username/followers", UserController, :show_followers)
    get("/@:username/following", UserController, :show_following)
    get("/@:username/card", UserController, :show_card)

    # Posts
    scope "/post" do
      post("/", PostController, :create)
      delete("/:id", PostController, :delete)
      get("/:hash", PostController, :show)
      get("/:hash/modal", PostController, :show_modal)

      # Post replies
      get("/:hash/replies", PostController, :show_replies)
      # Post Reactions
      post("/:hash/reactions", PostController, :add_reaction)
      delete("/:hash/reactions/:name", PostController, :remove_reaction)

      get("/:hash/reactions/overview", ReactionController, :reactions_overview)
      get("/:hash/reactions/:reaction_name", ReactionController, :reactions_by_name)
    end

    # Medias
    post("/medias", MediaController, :upload)

    # Links
    post("/links", LinkController, :process)

    # Favorites
    get("/favorites", FavoriteController, :list)
    post("/favorites/:post_id", FavoriteController, :create)
    delete("/favorites/:post_id", FavoriteController, :destroy)

    # Notifications
    get("/notifications", NotificationController, :index)
    put("/notifications/:id", NotificationController, :read)

    # Follows
    post("/user_follow", UserFollowController, :create)
    post("/user_follow/name", UserFollowController, :create_by_name)
    delete("/user_follow/:id", UserFollowController, :destroy)
    delete("/user_follow/name/:name", UserFollowController, :destroy_by_name)

    # Chat
    scope "/chat" do
      get("/", ChatController, :index)
      post("/", ChatController, :create)
      get("/conversations", ChatController, :list_conversations)
      get("/@:username", ChatController, :show)
      get("/:id/messages", ChatController, :show_messages)
      put("/:id", ChatController, :read)
    end

    # Tags
    get("/tag/:name", TagController, :show)
    put("/tag/:id", TagController, :update)

    get("/tags/popular", TagController, :list_popular)
    get("/tags/pinned", TagPinnedController, :list_pinned)

    # Tags subscriptions
    post("/tags/:tag_id/sub", TagSubscriptionController, :subscribe)
    delete("/tags/:tag_id/sub", TagSubscriptionController, :unsubscribe)

    # Search
    get("/search/:query", SearchController, :search)
    get("/search_typeahead/user/:username", SearchController, :user_typeahead)

    # Reports
    post("/reports/post/:post_id", ReportController, :create_post_report)

    # Subscriptions
    scope "/subs" do
      get("/", TagSubscriptionController, :index)
      get("/tags", TagSubscriptionController, :index)
    end

    # Blocks
    scope "/blocks" do
      get("/", BlockController, :index)
      post("/", BlockController, :create)
      delete("/:id", BlockController, :destroy)
    end

    scope "/moderation", Moderation do
      pipe_through(:admin)

      # Dashboard
      get("/", DashboardController, :index)

      # Audit
      get("/audit", AuditController, :index)

      # Bans
      get("/bans", BanController, :index)
      post("/bans/unban", BanController, :unban)
      post("/ban/user/:canonical", BanController, :ban)

      # Posts
      post("/post/update_tags", TagController, :update_tags)

      # Disabled posts
      get("/disabled_posts", DisabledPostController, :index)
      put("/disabled_posts/:post_id/restore", DisabledPostController, :restore)

      # Reports
      get("/reports", ReportsController, :index)
      put("/reports/post/:post_id", ReportsController, :resolve)

      put(
        "/reports/post/:post_id/nsfw_and_resolve",
        ReportsController,
        :mark_post_nsfw_and_resolve
      )

      put(
        "/reports/post/:post_id/disable_and_resolve",
        ReportsController,
        :disable_post_and_resolve
      )

      get("/reports/post/:post_id/comments", ReportsController, :show_comments)

      # Users
      get("/users", UserController, :index)
      get("/users/list.json", UserController, :list_users)
      put("/users/:user_id", UserController, :update)
      delete("/users/:user_id/avatar", UserController, :remove_avatar)
      delete("/users/:user_id/cover", UserController, :remove_cover)

      # Roles
      get("/roles", RoleController, :index)
      put("/roles/:role_id", RoleController, :update)
    end
  end
end
