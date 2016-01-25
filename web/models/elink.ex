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

  def slug(elink) do
    s = Hashids.new(min_len: 5)
    Hashids.encode(s, elink.id)
  end

  def by_slug(slug) do
    s = Hashids.new(min_len: 5)
    {:ok, [id]} = Hashids.decode(s, slug)
    from e in __MODULE__,
      where: e.id == ^id
  end

  def short_url(elink) do
    "#{elink.domain.domain}/#{slug(elink)}"
  end
end
