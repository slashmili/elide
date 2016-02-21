defmodule Elide.TestHelpers do
  alias Elide.{Repo, User, Organization, Domain, Elink, Token}

  def get_uniqe_id() do
    Base.encode16(:crypto.rand_bytes(8))
  end

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      fullname: "Foo Barian",
      email: "#{Base.encode16(:crypto.rand_bytes(8))}@foo.com",
      provider: "google",
      uid: Base.encode16(:crypto.rand_bytes(8))
    }, attrs)

    %Elide.User{}
    |> Elide.User.changeset(changes)
    |> Repo.insert!
  end

  def insert_organization(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Foo Org",
      user: nil
    }, attrs)

    %Organization{}
    |> Organization.changeset(changes)
    |> Repo.insert!
  end

  def insert_domain(attrs \\ %{}) do
    changes = Dict.merge(%{
      domain: "domain-#{get_uniqe_id}.com",
    }, attrs)

    %Domain{}
    |> Domain.changeset(changes)
    |> Repo.insert!
  end

  def insert_elink(attrs \\ %{}) do
    changes = Dict.merge(%{
    }, attrs)

    %Elink{}
    |> Elink.changeset(changes)
    |> Repo.insert!
  end

  def insert_token(attrs \\ %{}) do
    changes = Dict.merge(%{
    }, attrs)

    %Token{}
    |> Token.changeset(changes)
    |> Repo.insert!
  end
end
