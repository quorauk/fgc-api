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

  scope "/", FgcWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index

    get "/login", SessionController, :new
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout
  end

  scope "/", FgcWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/protected", PageController, :protected_json
  end

  scope "/api", FgcWeb do
    pipe_through [:api, :auth]

    post "/login", SessionController, :json_login
  end

  # Other scopes may use custom stacks.
  scope "/api", FgcWeb do
    pipe_through [:api, :auth, :ensure_auth]

    get "/protected", PageController, :protected_json
  end
end
