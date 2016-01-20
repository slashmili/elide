defmodule Elide.Auth do
  import Plug.Conn
  alias Elide.OAuth2.Google

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        assign(conn, :current_user, user)
      user = user_id && repo.get(Elide.User, user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must be logged in to access that page")
      |> Phoenix.Controller.redirect(to: "/")
      |> halt()
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> put_session(:user_id, nil)
    |> configure_session(renew: true)
  end

  def authorize_url!("google"),   do: Google.authorize_url!(scope: "https://www.googleapis.com/auth/userinfo.email")
  def authorize_url!(_), do: raise "No matching provider available"

  def get_user_details!("google", code) do
    user =
      [code: code]
      |> Google.get_token!
      |> Google.get_user_details!

    %{
      email: user["email"],
      fullname: "#{user["given_name"]} #{user["family_name"]}",
      uid: user["sub"],
      provider: "google",
      avatar: user["picture"]
    }
  end

end
