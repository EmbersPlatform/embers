defmodule EmbersWeb.Router do
  use EmbersWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(EmbersWeb.Authenticate)
    plug(Phauxth.Remember, create_session_func: &EmbersWeb.Auth.Utils.create_session/1)
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

    scope "/api" do
      scope "/v1" do
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
        post("/subscriptions/tags", TagController, :subscribe)
        delete("/subscriptions/tags/:id", TagController, :unsubscribe)

        get("/followers/:id/ids", FollowerController, :list_ids)
        get("/followers/:id/list", FollowerController, :list)

        resources("/posts", PostController, only: [:show, :create, :delete])
        get("/posts/:id/replies", PostController, :show_replies)

        post("/posts/:post_id/reaction/:name", ReactionController, :create)
        delete("/posts/:post_id/reaction/:name", ReactionController, :delete)

        get("/feed", FeedController, :timeline)
        get("/feed/public", FeedController, :get_public_feed)
        get("/feed/user/:id", FeedController, :user_statuses)

        post("/media", MediaController, :upload)

        get("/notifications", NotificationController, :index)
      end
    end

    get("/*path", PageController, :index)
  end
end
