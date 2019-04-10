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
    plug(GetPermissions)
    plug(Phauxth.Remember, create_session_func: &EmbersWeb.Auth.Utils.create_session/1)
  end

  pipeline :admin do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(EmbersWeb.Authenticate)
    plug(Phauxth.Remember, create_session_func: &EmbersWeb.Auth.Utils.create_session/1)
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

    get("/roles", EmbersWeb.Admin.RoleController, :index)
    get("/roles/new", EmbersWeb.Admin.RoleController, :new)
    post("/roles/new", EmbersWeb.Admin.RoleController, :create)
    get("/roles/edit/:rolename", EmbersWeb.Admin.RoleController, :edit)
    put("/roles/edit/:rolename", EmbersWeb.Admin.RoleController, :update)
    delete("/roles/:name", EmbersWeb.Admin.RoleController, :destroy)

    match(:*, "/*not_found", EmbersWeb.Admin.DashboardController, :not_found)
  end

  scope "/", EmbersWeb do
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    delete("/sessions", SessionController, :delete)
    get("/confirm", ConfirmController, :index)

    get("/password_resets/new", PasswordResetController, :new)
    post("/password_resets/new", PasswordResetController, :create)
    get("/password_resets/edit", PasswordResetController, :edit)
    put("/password_resets/edit", PasswordResetController, :update)

    get("/register", AccountController, :new)
    post("/register", AccountController, :create)

    get("/auth_data", PageController, :auth)

    scope "/api" do
      scope "/v1" do
        post("/auth", SessionController, :create_api)

        get("/users/:id", UserController, :show)

        put("/account/meta", MetaController, :update)
        post("/account/avatar", MetaController, :upload_avatar)
        post("/account/cover", MetaController, :upload_cover)
        put("/account/settings", SettingController, :update)

        get("/friends/:id/ids", FriendController, :list_ids)
        get("/friends/:id/list", FriendController, :list)
        post("/friends", FriendController, :create)
        post("/friends/name", FriendController, :create_by_name)
        delete("/friends/:id", FriendController, :destroy)
        delete("/friends/name/:name", FriendController, :destroy_by_name)

        get("/blocks/ids", BlockController, :list_ids)
        get("/blocks/list", BlockController, :list)
        post("/blocks", BlockController, :create)
        delete("/blocks/:id", BlockController, :destroy)

        get("/subscriptions/tags/ids", TagController, :list_ids)
        get("/subscriptions/tags/list", TagController, :list)
        post("/subscriptions/tags", TagController, :create)
        delete("/subscriptions/tags/:id", TagController, :destroy)

        get("/followers/:id/ids", FriendController, :list_ids)
        get("/followers/:id/list", FriendController, :list)

        resources("/posts", PostController, only: [:show, :create, :delete])
        get("/posts/:id/replies", PostController, :show_replies)

        post("/posts/:post_id/reaction/:name", ReactionController, :create)
        delete("/posts/:post_id/reaction/:name", ReactionController, :delete)

        get("/feed", FeedController, :timeline)
        get("/feed/public", FeedController, :get_public_feed)
        get("/feed/user/:id", FeedController, :user_statuses)

        get("/feed/favorites", FavoriteController, :list)
        post("/feed/favorites/:post_id", FavoriteController, :create)
        delete("/feed/favorites/:post_id", FavoriteController, :destroy)

        post("/media", MediaController, :upload)

        get("/notifications", NotificationController, :index)
        put("/notifications/:id", NotificationController, :read)
      end
    end

    get("/*path", PageController, :index)
  end
end
