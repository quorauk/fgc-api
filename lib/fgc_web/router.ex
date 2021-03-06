defmodule FgcWeb.Router do
  use FgcWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Fgc.UserManager.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FgcWeb do
    pipe_through [:api, :auth]

    post "/login", SessionController, :json_login

    delete "/logout", SessionController, :json_logout
  end

  # Other scopes may use custom stacks.
  scope "/api", FgcWeb do
    pipe_through [:api, :auth, :ensure_auth]

    get "/me", SessionController, :me

    get "/me/webhook_token", SessionController, :webhook_token

    get "/validate-login", SessionController, :validate_login

    get "/me/scoreboards", ScoreboardController, :index
    post "/me/scoreboards", ScoreboardController, :create

    get "/me/scoreboards/:id", ScoreboardController, :get
    delete "/me/scoreboards/:id", ScoreboardController, :delete
  end
end
