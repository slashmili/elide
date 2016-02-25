defmodule Elide.MembershipController do
  use Elide.Web, :controller

  alias Elide.{Membership, Organization, User}

  plug :scrub_params, "membership" when action in [:create, :update]

  def action(conn, _) do
    organization = Repo.get!(
      Organization.owned_by(conn.assigns[:current_user]),
      conn.params["organization_id"]
    )

    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user, organization])
  end


  def index(conn, _param, _user, org) do
    memberships =
      org
      |> Membership.for_organization
      |> Ecto.Query.preload(:user)
      |> Repo.all
    render(conn, "index.html", memberships: memberships, org: org)
  end

  def new(conn, _param, _user, org) do
    changeset = Membership.changeset(%Membership{})
    render(conn, "new.html", changeset: changeset, org: org)
  end

  def create(conn, %{"membership" => membership_params}, _user, org) do
    user = Repo.get_by(User, email: membership_params["user_email"] || "")
    user_id = user && user.id || 0
    membership_params = Dict.delete membership_params, "role"
    changeset = Membership.changeset(
      %Membership{role: "m", user_id: user_id, organization_id: org.id},
      membership_params
    )

    case user && Repo.insert(changeset) do
      {:ok, _membership} ->
        conn
        |> put_flash(:info, "Membership created successfully.")
        |> redirect(to: organization_membership_path(conn, :index, org.id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, org: org)
      nil ->
        render(conn, "new.html", changeset: changeset, org: org)
    end
  end

  def delete(conn, %{"id" => id}, _user, org) do
    membership = Repo.get_by!(Membership, %{id: id, organization_id: org.id})

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(membership)

    conn
    |> put_flash(:info, "Membership deleted successfully.")
    |> redirect(to: organization_membership_path(conn, :index, org.id))
  end
end
