defmodule TodoAppWeb.Router do
  use TodoAppWeb, :router
  import Phoenix.LiveView.Router
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TodoAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TodoAppWeb do
  pipe_through :browser

  get "/", PageController, :home

  live "/todos", TodoLive.Index, :index
  live "/todos/new", TodoLive.Index, :new
  live "/todos/:id/edit", TodoLive.Index, :edit
  live "/todos/:id", TodoLive.Show, :show
  live "/todos/:id/show/edit", TodoLive.Show, :edit
end


  # Other scopes may use custom stacks.
  # scope "/api", TodoAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:todo_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TodoAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
