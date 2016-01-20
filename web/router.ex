defmodule Elide.Router do
  use Elide.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
    pipe_through [:browser, :authenticate_user]
    resources "/org", OrganizationController do
      resources "/members", MembershipController
    end
  end

  scope "/users/auth", Elide do
    pipe_through :browser

    get "/:provider", UserController, :provider
    get "/:provider/callback", UserController, :callback
    #delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Elide do
  #   pipe_through :api
  # end
end
