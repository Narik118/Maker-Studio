defmodule TaskManagementWeb.Router do
  use TaskManagementWeb, :router

  import TaskManagementWeb.Plug.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskManagementWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # for auth
  pipeline :api_no_auth do
    plug :accepts, ["json"]
  end

  # need auth
  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_user
  end

  scope "/", TaskManagementWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api/v1", TaskManagementWeb do
    pipe_through :api_no_auth

    post "/users", User.UserController, :create
    post "/signin", Auth.SigninController, :signin
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", TaskManagementWeb do
    pipe_through :api

    post "/users/:user_id/tasks", Task.TaskController, :create
    get "/users/:user_id/tasks", Task.TaskController, :get_all_tasks
    get "/users/:user_id/tasks/:task_id", Task.TaskController, :get_task
    put "/users/:user_id/tasks/:task_id", Task.TaskController, :update_task
    delete "/users/:user_id/tasks/:task_id", Task.TaskController, :delete_task
    # match :*, "/", ErrorController, :not_found
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:task_management, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TaskManagementWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
