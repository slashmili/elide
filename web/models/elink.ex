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

  @doc """
  Returns short url hash based on elink
  """
  def slug(elink) do
    s = Hashids.new(min_len: 5, salt: salt)
    Hashids.encode(s, elink.id)
  end

  @doc """
  Returns query based on short hash url

  This query should return only one `Elink` item
  """
  def by_slug(slug) do
    s = Hashids.new(min_len: 5, salt: salt)
    {:ok, [id]} = Hashids.decode(s, slug)
    from e in __MODULE__,
      where: e.id == ^id
  end

  @doc """
  Returns full short link
  """
  def short_url(elink) do
    "#{elink.domain.domain}/#{slug(elink)}"
  end

  def salt do
    config = Application.get_env(:elide, __MODULE__)
    config[:hashid_salt]
  end
end
