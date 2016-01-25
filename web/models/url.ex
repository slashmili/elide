defmodule Elide.Url do
  use Elide.Web, :model

  schema "urls" do
    field :link, :string
    belongs_to :elink, Elide.Elink

    timestamps
  end

  @required_fields ~w(link)
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
