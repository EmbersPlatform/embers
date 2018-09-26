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
        put("/users/profile/meta", MetaController, :update)
        post("/users/profile/avatar", MetaController, :upload_avatar)
        post("/users/profile/cover", MetaController, :upload_cover)

        put("/users/settings", SettingController, :update)

        resources("/posts", PostController, only: [:show, :create, :update, :delete])

        get("/feed", FeedController, :timeline)
      end
    end

    get("/*path", PageController, :index)
  end
end
