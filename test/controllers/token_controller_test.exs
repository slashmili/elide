defmodule Elide.TokenControllerTest do
  use Elide.ConnCase

  alias Elide.Token
  @valid_attrs %{description: "some content"}
  @invalid_attrs %{}

  setup do
    user = insert_user(email: "foobar@buz.com")
    conn = assign(conn(), :current_user, user)
    domain = insert_domain()
    {:ok, conn: conn, user: user, domain: domain}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, token_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing tokens"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, token_path(conn, :new)
    assert html_response(conn, 200) =~ "New token"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    valid_attrs = %{description: "foo", user_id: user.id}
    conn = post conn, token_path(conn, :create), token: valid_attrs
    assert redirected_to(conn) == token_path(conn, :index)
    assert Repo.get_by(Token, valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, token_path(conn, :create), token: @invalid_attrs
    assert html_response(conn, 200) =~ "New token"
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    token = Repo.insert! %Token{user_id: user.id}
    conn = delete conn, token_path(conn, :delete, token)
    assert redirected_to(conn) == token_path(conn, :index)
    refute Repo.get(Token, token.id)
  end
end
