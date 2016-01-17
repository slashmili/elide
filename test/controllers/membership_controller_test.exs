defmodule Elide.MembershipControllerTest do
  use Elide.ConnCase

  alias Elide.Membership
  @valid_attrs %{role: "some content"}
  @invalid_attrs %{}

  setup do
    user = insert_user(email: "foobar@buz.com")
    organization = insert_organization(owner_id: user.id)
    conn = assign(conn(), :current_user, user)
    conn = assign(conn(), :organization, organization)
    {:ok, conn: conn, user: user}
  end

  @tag :skip
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, organization_membership_path(conn, :index, conn.assigns[:organization].id)
    assert html_response(conn, 200) =~ "Listing memberships"
  end

  #test "renders form for new resources", %{conn: conn} do
  #  conn = get conn, membership_path(conn, :new)
  #  assert html_response(conn, 200) =~ "New membership"
  #end

  #test "creates resource and redirects when data is valid", %{conn: conn} do
  #  conn = post conn, membership_path(conn, :create), membership: @valid_attrs
  #  assert redirected_to(conn) == membership_path(conn, :index)
  #  assert Repo.get_by(Membership, @valid_attrs)
  #end

  #test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #  conn = post conn, membership_path(conn, :create), membership: @invalid_attrs
  #  assert html_response(conn, 200) =~ "New membership"
  #end

  #test "deletes chosen resource", %{conn: conn} do
  #  membership = Repo.insert! %Membership{}
  #  conn = delete conn, membership_path(conn, :delete, membership)
  #  assert redirected_to(conn) == membership_path(conn, :index)
  #  refute Repo.get(Membership, membership.id)
  #end
end
