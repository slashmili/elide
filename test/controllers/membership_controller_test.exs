defmodule Elide.MembershipControllerTest do
  use Elide.ConnCase

  alias Elide.Membership

  setup do
    user = insert_user(email: "foobar@buz.com")
    organization = insert_organization(owner_id: user.id)
    conn = assign(conn(), :current_user, user)
    conn = assign(conn, :organization, organization)
    {:ok, conn: conn, user: user, org: organization}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, organization_membership_path(conn, :index, conn.assigns[:organization].id)
    assert html_response(conn, 200) =~ "Listing memberships"
  end

  test "renders form for new resources", %{conn: conn, user: _user, org: org} do
    conn = get conn, organization_membership_path(conn, :new, org.id)
    assert html_response(conn, 200) =~ "New membership"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, user: user, org: org} do
    conn = post conn, organization_membership_path(conn, :create, org.id), membership: %{user_email: user.email}
    assert redirected_to(conn) == organization_membership_path(conn, :index, org.id)
    assert Repo.get_by(Membership, %{user_id: user.id})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: _user, org: org} do
    conn = post conn, organization_membership_path(conn, :create, org.id), membership: %{user_email: ""}
    assert html_response(conn, 200) =~ "New membership"
  end

  test "deletes chosen resource", %{conn: conn, user: user, org: org} do
    membership = Repo.insert! %Membership{user_id: user.id, organization_id: org.id}
    conn = delete conn, organization_membership_path(conn, :delete, org.id, membership)
    assert redirected_to(conn) == organization_membership_path(conn, :index, org.id)
    refute Repo.get(Membership, membership.id)
  end
end
