defmodule Elide.Stat do
  use Elide.Web, :model

  schema "stats" do
    field :tag, :string
    field :value, :string
    field :count, :integer
    field :visiting_interval, Timex.Ecto.DateTime
    belongs_to :elink, Elide.Elink
    belongs_to :url, Elide.Url

    timestamps
  end

  @required_fields ~w(elink_id tag value count visiting_interval)
  @optional_fields ~w(url_id)

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

  def get_tags do
    @valid_tags
  end
end
