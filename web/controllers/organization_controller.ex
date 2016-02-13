defmodule Elide.OrganizationController do
  use Elide.Web, :controller

  alias Elide.Organization

  plug :scrub_params, "organization" when action in [:create, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    organizations = Repo.all(Organization.owned_by(user))
    render(conn, "index.html", organizations: organizations)
  end

  def new(conn, _params, _user) do
    changeset = Organization.changeset(%Organization{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"organization" => organization_params}, user) do
    changeset = Organization.changeset(
      %Organization{owner_id: user.id},
      organization_params
    )

    case Repo.insert(changeset) do
      {:ok, _organization} ->
        conn
        |> put_flash(:info, "Organization created successfully.")
        |> redirect(to: organization_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    organization = Repo.get!(Organization.owned_by(user), id)
    render(conn, "show.html", organization: organization)
  end

  def edit(conn, %{"id" => id}, user) do
    organization = Repo.get!(Organization.owned_by(user), id)
    changeset = Organization.changeset(organization)
    render(conn, "edit.html", organization: organization, changeset: changeset)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}, user) do
    organization = Repo.get!(Organization.owned_by(user), id)
    organization = %{organization | owner_id: user.id}
    changeset = Organization.changeset(organization, organization_params)

    case Repo.update(changeset) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization updated successfully.")
        |> redirect(to: organization_path(conn, :show, organization))
      {:error, changeset} ->
        render(conn, "edit.html", organization: organization, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    organization = Repo.get!(Organization.owned_by(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(organization)

    conn
    |> put_flash(:info, "Organization deleted successfully.")
    |> redirect(to: organization_path(conn, :index))
  end
end
