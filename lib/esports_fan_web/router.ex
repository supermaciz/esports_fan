defmodule EsportsFanWeb.Router do
  use EsportsFanWeb, :router

  import Oban.Web.Router
  import EsportsFanWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EsportsFanWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EsportsFanWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", ExampleLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", EsportsFanWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:esports_fan, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EsportsFanWeb.Telemetry, repos: [EsportsFan.Repo]
      forward "/mailbox", Plug.Swoosh.MailboxPreview
      oban_dashboard("/oban")
    end
  end

  ## Authentication routes

  scope "/", EsportsFanWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{EsportsFanWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      live "/user_subscriptions", UserSubscriptionLive.Index, :index
      live "/user_subscriptions/new", UserSubscriptionLive.Form, :new
      live "/user_subscriptions/:id/edit", UserSubscriptionLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", EsportsFanWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{EsportsFanWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
