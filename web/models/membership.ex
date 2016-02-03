defmodule Elide.Membership do
  use Elide.Web, :model

  schema "memberships" do
    field :role, :string
    belongs_to :user, Elide.User
    belongs_to :organization, Elide.Organization
    field :user_email, :string, virtual: true

    timestamps
  end

  @required_fields ~w(role user_id organization_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:role, ["m"])
  end

  @doc """
  Returns query that match all the memberships for given organization
  """
  def for_organization(organization) do
    from m in __MODULE__, where: m.organization_id == ^organization.id
  end
end
