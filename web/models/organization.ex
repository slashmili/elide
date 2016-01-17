defmodule Elide.Organization do
  use Elide.Web, :model

  schema "organizations" do
    field :name, :string
    belongs_to :owner, Elide.Owner

    timestamps
  end

  @required_fields ~w(name owner_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def owned_by(user) do
    from o in __MODULE__, where: o.owner_id == ^user.id
  end
end
