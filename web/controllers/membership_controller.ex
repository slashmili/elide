defmodule Elide.MembershipController do
  use Elide.Web, :controller

  alias Elide.{Membership, Organization, User}

  plug :scrub_params, "membership" when action in [:create, :update]
  plug :get_organization

  def get_organization(conn, opts) do
    organization = Repo.get!(
      Organization.owned_by(conn.assigns[:current_user]),
      conn.params["organization_id"]
    )

    assign(conn, :organization, organization)
  end

  def index(conn, %{"organization_id" => organization_id}) do
    memberships = Membership.for_organization(conn.assigns[:organization])
    |> Ecto.Query.preload(:user)
    |> Repo.all
    render(conn, "index.html", memberships: memberships, organization_id: organization_id)
  end

  def new(conn, %{"organization_id" => organization_id}) do
    changeset = Membership.changeset(%Membership{})
    render(conn, "new.html", changeset: changeset, organization_id: organization_id)
  end

  def create(conn, %{"membership" => membership_params, "organization_id" => organization_id}) do
    organization = conn.assigns[:organization]
    user = Repo.get_by!(User, email: membership_params["user_email"])
    membership_params = Dict.delete membership_params, "role"
    changeset = Membership.changeset(
      %Membership{role: "m", user_id: user.id, organization_id: organization.id},
      membership_params
    )

    case Repo.insert(changeset) do
      {:ok, _membership} ->
        conn
        |> put_flash(:info, "Membership created successfully.")
        |> redirect(to: organization_membership_path(conn, :index, organization_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, organization_id: organization_id)
    end
  end

  def delete(conn, %{"id" => id, "organization_id" => organization_id}) do
    membership = Repo.get!(Membership, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(membership)

    conn
    |> put_flash(:info, "Membership deleted successfully.")
    |> redirect(to: organization_membership_path(conn, :index, organization_id))
  end
end
