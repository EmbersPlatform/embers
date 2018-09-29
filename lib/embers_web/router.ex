defmodule EmbersWeb.Router do
  use EmbersWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Phauxth.Authenticate)
    plug(Phauxth.Remember)
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

    post("/register", AccountController, :create)

    scope "/api" do
      scope "/v1" do
        get("/users/:id", UserController, :show)

        put("/account/meta", MetaController, :update)
        post("/account/avatar", MetaController, :upload_avatar)
        post("/account/cover", MetaController, :upload_cover)
        put("/account/settings", SettingController, :update)

        get("/friends/:user_id/ids", FriendController, :list_ids)
        get("/friends/:user_id/list", FriendController, :list)
        post("/friends", FriendController, :create)
        delete("/friends", FriendController, :destroy)

        get("/followers/:user_id/ids", FollowerController, :list_ids)
        get("/followers/:user_id/list", FollowerController, :list)
        post("/followers", FollowerController, :create)
        delete("/followers", FollowerController, :destroy)

        resources("/posts", PostController, only: [:show, :create, :delete])
        get("/posts/:id/replies", PostController, :show_replies)

        get("/feed", FeedController, :timeline)
      end
    end

    get("/*path", PageController, :index)
  end
end
