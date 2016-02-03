defmodule Elide.Auth do
  import Plug.Conn
  alias Elide.OAuth2.Google

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  @doc """
  Gets the logged in user from session
  """
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

  @doc """
  Returns the user if exists in conn, otherwise redirect user to home
  """
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

  @doc """
  Prepares client's session to keep the logged in user
  """
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  @doc """
  Cleans up client's session
  """
  def logout(conn) do
    conn
    |> put_session(:user_id, nil)
    |> configure_session(renew: true)
  end

  @doc """
  Authorizes received token through google api

  For now we only support google as oauth provider
  """
  def authorize_url!("google"),   do: Google.authorize_url!()

  def authorize_url!(_), do: raise "No matching provider available"

  @doc """
  Gets user's details based on google oauth response
  """
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
