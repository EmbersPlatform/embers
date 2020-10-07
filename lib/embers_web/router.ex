defmodule EmbersWeb.Router do
  use EmbersWeb, :router

  alias EmbersWeb.Plugs.{CheckPermissions, GetPermissions}

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(EmbersWeb.Authenticate)
    plug(EmbersWeb.Remember)
    plug(GetPermissions)
    plug(EmbersWeb.Plugs.SelectLayout)
    plug(EmbersWeb.Plugs.ModData)
  end

  pipeline :admin do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(EmbersWeb.Authenticate)
    plug(EmbersWeb.Remember)
    plug(GetPermissions)
    plug(CheckPermissions, permission: "access_backoffice")

    plug(
      Plug.Static,
      at: "/admin",
      from: Path.expand('./priv/static/admin'),
      gzip: true
    )

    plug(:protect_from_forgery)
  end

  scope "/admin" do
    pipe_through([:admin])

    get("/", EmbersWeb.Admin.DashboardController, :index)

    get("/users", EmbersWeb.Admin.UserController, :index)
    get("/users/edit/:name", EmbersWeb.Admin.UserController, :edit)
    put("/users/edit/:name", EmbersWeb.Admin.UserController, :update)
    patch("/users/confirm/:id", EmbersWeb.Admin.UserController, :confirm)
    post("/users/send_pw_reset/:email", EmbersWeb.Admin.UserController, :send_password_reset)

    get("/roles", EmbersWeb.Admin.RoleController, :index)
    get("/roles/new", EmbersWeb.Admin.RoleController, :new)
    post("/roles/new", EmbersWeb.Admin.RoleController, :create)
    get("/roles/edit/:rolename", EmbersWeb.Admin.RoleController, :edit)
    put("/roles/edit/:rolename", EmbersWeb.Admin.RoleController, :update)
    delete("/roles/:name", EmbersWeb.Admin.RoleController, :destroy)

    get("/settings", EmbersWeb.Admin.SettingController, :index)
    get("/settings/edit/:name", EmbersWeb.Admin.SettingController, :edit)
    put("/settings/edit/:name", EmbersWeb.Admin.SettingController, :update)

    get("/reports", EmbersWeb.Admin.ReportController, :overview)
    get("/reports/post/:id", EmbersWeb.Admin.ReportController, :post_report)
    delete("/reports/post/:id", EmbersWeb.Admin.ReportController, :delete_post)
    put("/reports/post/:id", EmbersWeb.Admin.ReportController, :resolve_post_reports)

    get("/bans", EmbersWeb.Admin.BanController, :index)
    get("/bans/:user_id", EmbersWeb.Admin.BanController, :show)
    delete("/bans/:user_id", EmbersWeb.Admin.BanController, :delete)

    get("/audit", EmbersWeb.Admin.AuditController, :index)

    get("/tags", EmbersWeb.Admin.TagController, :index)
    get("/tags/:name", EmbersWeb.Admin.TagController, :edit)
    put("/tags/:name", EmbersWeb.Admin.TagController, :update)

    resources("/loading", EmbersWeb.Admin.LoadingMsgController)

    match(:*, "/*not_found", EmbersWeb.Admin.DashboardController, :not_found)
  end

  scope "/" do
    pipe_through(:browser)
    get("/auth_data", EmbersWeb.Api.PageController, :auth)
  end

  scope "/", EmbersWeb.Web do
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/static/rules", PageController, :rules)
    get("/static/faq", PageController, :faq)
    get("/static/acknowledgments", PageController, :acknowledgments)

    # Authentication
    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    delete("/sessions", SessionController, :delete)
    get("/confirm", ConfirmController, :index)

    # Password reset
    get("/password_resets/new", PasswordResetController, :new)
    post("/password_resets/new", PasswordResetController, :create)
    get("/password_resets/edit", PasswordResetController, :edit)
    put("/password_resets/edit", PasswordResetController, :update)

    # Account creation
    get("/register", AccountController, :new)
    post("/register", AccountController, :create)

    # Settings
    get("/settings", SettingsController, :show_profile)
    patch("/settings", SettingsController, :update)
    post("/settings/reset_pass", SettingsController, :reset_pass)
    get("/settings/profile", SettingsController, :show_profile)
    patch("/settings/profile/update_profile", SettingsController, :update_profile)
    post("/settings/profile/update_cover", SettingsController, :update_cover)
    post("/settings/profile/update_avatar", SettingsController, :update_avatar)
    get("/settings/content", SettingsController, :show_content)
    get("/settings/design", SettingsController, :show_design)
    get("/settings/privacy", SettingsController, :show_privacy)
    get("/settings/security", SettingsController, :show_security)

    # Feeds
    get("/timeline", TimelineController, :index)
    get("/discover", DiscoverController, :index)

    # User profile
    get("/@:username", UserController, :show)
    get("/user/:user_id/timeline", UserController, :timeline)
    get("/@:username/followers", UserController, :show_followers)
    get("/@:username/following", UserController, :show_following)

    # Posts
    post("/post", PostController, :create)
    delete("/post/:id", PostController, :delete)
    get("/post/:hash", PostController, :show)
    get("/post/:hash/modal", PostController, :show_modal)

    # Post replies
    get("/post/:hash/replies", PostController, :show_replies)
    # Post Reactions
    post("/post/:hash/reactions", PostController, :add_reaction)
    delete("/post/:hash/reactions/:name", PostController, :remove_reaction)

    get("/post/:hash/reactions/overview", ReactionController, :reactions_overview)
    get("/post/:hash/reactions/:reaction_name", ReactionController, :reactions_by_name)

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
    get("/chat", ChatController, :index)
    post("/chat", ChatController, :create)
    get("/chat/conversations", ChatController, :list_conversations)
    get("/chat/@:username", ChatController, :show)
    get("/chat/:id/messages", ChatController, :show_messages)
    put("/chat/:id", ChatController, :read)

    # Tags
    get("/tag/:name", TagController, :show)
    get("/tags/popular", TagController, :list_popular)

    # Tags subscriptions
    post("/tags/:tag_id/sub", TagSubscriptionController, :subscribe)
    delete("/tags/:tag_id/sub", TagSubscriptionController, :unsubscribe)

    # Search
    get("/search/:query", SearchController, :search)
    get("/search_typeahead/user/:username", SearchController, :user_typeahead)


    # Reports
    post("/reports/post/:post_id", ReportController, :create_post_report)

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
      put("/reports/post/:post_id/nsfw_and_resolve", ReportsController, :mark_post_nsfw_and_resolve)
      put("/reports/post/:post_id/disable_and_resolve", ReportsController, :disable_post_and_resolve)
      get("/reports/post/:post_id/comments", ReportsController, :show_comments)

      # Users
      get("/users", UserController, :index)
    end
  end

  scope "/api/v1", EmbersWeb.Api, as: :api do
    pipe_through(:browser)
    # should be deprecated?
    # post("/auth",SessionController, :create_api)

    # User
    get("/users/:id", UserController, :show)

    # Account settings
    put("/account/meta", MetaController, :update)
    post("/account/avatar", MetaController, :upload_avatar)
    post("/account/cover", MetaController, :upload_cover)
    put("/account/settings", SettingController, :update)
    post("/account/reset_pass", UserController, :reset_pass)

    # Mod specific routes
    # TODO move to an admin protected scope
    post("/moderation/ban", ModerationController, :ban_user)
    post("/moderation/post/update_tags", ModerationController, :update_tags)

    post("/friends", FriendController, :create)
    post("/friends/name", FriendController, :create_by_name)
    delete("/friends/:id", FriendController, :destroy)
    delete("/friends/name/:name", FriendController, :destroy_by_name)

    get("/blocks/ids", BlockController, :list_ids)
    get("/blocks/list", BlockController, :list)
    post("/blocks", BlockController, :create)
    delete("/blocks/:id", BlockController, :destroy)

    get("/tag_blocks/ids", TagBlockController, :list_ids)
    get("/tag_blocks/list", TagBlockController, :list)
    post("/tag_blocks", TagBlockController, :create)
    delete("/tag_blocks/:id", TagBlockController, :destroy)

    get("/tags/popular", TagController, :popular)
    get("/tags/hot", TagController, :hot)

    get("/subscriptions/tags/ids", TagController, :list_ids)
    get("/subscriptions/tags/list", TagController, :list)
    post("/subscriptions/tags", TagController, :create)
    delete("/subscriptions/tags/:id", TagController, :destroy)

    get("/tags/:name", TagController, :show_tag)
    get("/tags/:name/posts", TagController, :show_tag_posts)

    get("/following/:id/ids", FriendController, :list_ids)
    get("/following/:id/list", FriendController, :list)
    get("/followers/:id/ids", FriendController, :list_followers_ids)
    get("/followers/:id/list", FriendController, :list_followers)

    resources("/posts", PostController, only: [:show, :create, :delete])
    get("/posts/:id/replies", PostController, :show_replies)
    post("/posts/:post_id/reaction/:name", ReactionController, :create)
    delete("/posts/:post_id/reaction/:name", ReactionController, :delete)
    post("/posts/:post_id/report", PostReportController, :create)

    get(
      "/posts/:post_id/reactions/overview",
      ReactionController,
      :reactions_overview
    )

    get(
      "/posts/:post_id/reactions/:reaction_name",
      ReactionController,
      :reactions_by_name
    )

    get("/reactions/valid", ReactionController, :list_valid_reactions)

    get("/feed", FeedController, :timeline)
    get("/feed/public", FeedController, :get_public_feed)
    get("/feed/user/:id", FeedController, :user_statuses)
    delete("/feed/activity/:id", FeedController, :hide_post)

    get("/feed/favorites", FavoriteController, :list)
    post("/feed/favorites/:post_id", FavoriteController, :create)
    delete("/feed/favorites/:post_id", FavoriteController, :destroy)

    post("/media", MediaController, :upload)
    post("/link", LinkController, :parse)

    get("/notifications", NotificationController, :index)
    put("/notifications/:id", NotificationController, :read)

    get("/search/:query", SearchController, :search)
    get("/search_typeahead/user/:username", SearchController, :user_typeahead)

    get("/chat/conversations", ChatController, :list_conversations)
    post("/chat/conversations", ChatController, :create)
    get("/chat/conversations/:id", ChatController, :list_messages)
    put("/chat/conversations/:id", ChatController, :read)
    get("/chat/unread", ChatController, :list_unread_conversations)
  end
end
