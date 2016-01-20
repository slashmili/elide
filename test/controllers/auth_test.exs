defmodule Elide.AuthTest do
  use Elide.ConnCase

  import Mock

  alias Elide.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Elide.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Elide.User{})
      |> Auth.authenticate_user([])
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Elide.User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")

    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()

    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "redirect to google when request for auth", %{conn: conn} do
    conn = get conn, user_path(conn, :provider, "google")

    assert conn.halted
  end

  defp get_google_body_resp(email) do
    %{
      "email" => email, "email_verified" => "true",
      "family_name" => "Bar", "gender" => "other", "given_name" => "Foo",
      "kind" => "plus#personOpenIdConnect", "name" => "Foo Bar",
      "picture" => "https://lh3.googleusercontent.com/photo.jpg?sz=50",
      "profile" => "https://plus.google.com/107467950120292670586",
      "sub" => "107467950120292670586"
    }
  end

  test "new user returns back to callback url", %{conn: conn} do
    email = "foobar#{:rand.uniform}@gmail.com"
    resp_body = get_google_body_resp(email)
    with_mock Elide.OAuth2.Google, [get_token!: fn(_) -> "mocked_token" end, get_user_details!: fn(_) -> resp_body end] do
      get conn, user_path(conn, :callback, "google", %{code: "boo"})
    end

    user = Repo.get_by(Elide.User, %{email: email})

    assert user.email == email
  end

  test "existing user returns back to callback url", %{conn: conn} do
    user = insert_user()
    resp_body = get_google_body_resp(user.email)
    with_mock Elide.OAuth2.Google, [get_token!: fn(_) -> "mocked_token" end, get_user_details!: fn(_) -> resp_body end] do
      get conn, user_path(conn, :callback, "google", %{code: "boo"})
    end

    users_with_same_email = Repo.all(from u in Elide.User, where: u.email == ^user.email)
    assert Enum.count(users_with_same_email) == 1, "there should be only one user with this email"
    assert Enum.at(users_with_same_email, 0) == user
  end
end
