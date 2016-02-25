defmodule Elide.Elink do
  use Elide.Web, :model

  schema "elinks" do
    field :slug, :string
    field :elink_seq, :integer
    belongs_to :domain, Elide.Domain
    belongs_to :user, Elide.User
    belongs_to :organization, Elide.Organization
    has_many :urls, Elide.Url

    timestamps
  end

  @required_fields ~w(domain_id elink_seq)
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
    s = Hashids.new(min_len: 1, salt: salt)
    Hashids.encode(s, [elink.domain_id, elink.elink_seq])
  end

  @doc """
  Returns query based on short hash url

  This query should return only one `Elink` item
  """
  def by_slug(my_slug) do
    details = get_details_by_slug(my_slug)
    domain_id = details[:domain_id]
    elink_seq = details[:elink_seq]
    from e in __MODULE__,
      where: e.domain_id == ^domain_id and e.elink_seq == ^elink_seq
  end

  @doc """
  Returns full short link
  """
  def short_url(elink) do
    "#{elink.domain.domain}/#{slug(elink)}"
  end

  def get_details_by_slug(my_slug) do
    s = Hashids.new(min_len: 1, salt: salt)
    {:ok, [domain_id, elink_seq]} = Hashids.decode(s, my_slug)
    [domain_id: domain_id, elink_seq: elink_seq]
  end

  def salt do
    config = Application.get_env(:elide, __MODULE__)
    config[:hashid_salt]
  end
end
