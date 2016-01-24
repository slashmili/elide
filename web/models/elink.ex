defmodule Elide.Elink do
  use Elide.Web, :model

  schema "elinks" do
    field :slug, :string
    belongs_to :domain, Elide.Domain
    belongs_to :user, Elide.User
    belongs_to :organization, Elide.Organization
    has_many :urls, Elide.Url

    timestamps
  end

  @required_fields ~w(domain_id)
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
end
