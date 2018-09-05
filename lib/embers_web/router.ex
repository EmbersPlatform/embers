defmodule EmbersWeb.Router do
  use EmbersWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember
    plug Plug.Static,
		  at: "/", from: :embers, gzip: true,
		  only: ~w(css fonts img js favicon.ico robots.txt manifest.json offline.html error.html service-worker.js)
  end

  scope "/", EmbersWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/sessions", SessionController, only: [:create, :delete]
    get "/confirm", ConfirmController, :index
    resources "/password_resets", PasswordResetController, only: [:create]
    put "/password_resets", PasswordResetController, :update

    scope "/api" do
    	scope "/v1" do
    		resources "/users", UserController, only: [:index, :show, :create, :update, :delete]
    			resources "/users/profile/metas", MetaController, only: [:show, :update]
		    resources "/posts", PostController, only: [:index, :show, :create, :update, :delete]

		    get "/feed", FeedController, :timeline

    	end
    end

    get "/*path", PageController, :index
  end

end
