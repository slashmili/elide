defmodule Elide.UserController do
  use Elide.Web, :controller

  alias Elide.{User, Auth}

  def provider(conn, %{"provider" => my_provider}) do
    conn
    |> redirect(external: Auth.authorize_url!(my_provider))
    |> halt
  end

  def callback(conn, %{"provider" => my_provider, "code" => code}) do
    user =
      my_provider
      |> Auth.get_user_details!(code)
      |> get_or_create_user

    conn
    |> Elide.Auth.login(user)
    |> redirect(to: "/")
  end

  def get_or_create_user(user) do
    case Repo.get_by(User, %{email: user[:email]}) do
      nil ->
        changeset = User.changeset(%User{}, user)
        Repo.insert!(changeset)
      user -> user
    end
  end

end
