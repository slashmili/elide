defmodule Elide.Router do
  use Elide.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
    plug Elide.Auth, repo: Elide.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Elide do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/ui", Elide do
    pipe_through :browser
    resources "/org", OrganizationController do
      resources "/members", MembershipController
    end
  end

  scope "/auth", Elide do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
    #delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Elide do
  #   pipe_through :api
  # end
  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end
end
