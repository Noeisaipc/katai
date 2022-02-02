defmodule KataiWeb.Router do
  use KataiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api_auth do
    plug(Guardian.Plug.Pipeline,
      module: KataiWeb.Guardian,
      error_handler: KataiWeb.JsonAuthErrorHandler
    )

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :signature_validation do
    plug KataiWeb.Plug.HeadersValidation
    plug KataiWeb.Plug.SignatureValidation
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", KataiWeb do
  #   pipe_through :browser

  #   get "/", PageController, :index
  # end

  #Other scopes may use custom stacks.
  scope "/api/v1", KataiWeb do
    pipe_through :api

    post "/sign_in", MobileSessionController, :sign_in
    resources "/users", UserController, except: [:new, :edit]

    pipe_through(:api_auth)
    pipe_through(:signature_validation)
    post "/test_sign", MobileSessionController, :test_sign
    post "/sign_out", MobileSessionController, :sing_out
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: KataiWeb.Telemetry
    end
  end
end
