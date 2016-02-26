defmodule Elide.Stat do
  use Elide.Web, :model

  schema "stats" do
    field :tag, :string
    field :value, :string
    field :count, :integer
    field :visited_at, Ecto.DateTime
    belongs_to :elink, Elide.Elink

    timestamps
  end

  @required_fields ~w(tag value count visited_at)
  @optional_fields ~w()

  @valid_tags ["browser", "referrer", "country", "platform"]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:tag, @valid_tags)
  end
end
