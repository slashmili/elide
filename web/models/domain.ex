defmodule Elide.Domain do
  use Elide.Web, :model

  schema "domains" do
    field :domain, :string

    timestamps
  end

  @required_fields ~w(domain)
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

  def default_domain do
    from d in __MODULE__, order_by: d.id, limit: 1
  end

  def by_address(domain_name) do
    from d in __MODULE__, where: d.domain == ^domain_name
  end
end
