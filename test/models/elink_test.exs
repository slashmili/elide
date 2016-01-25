defmodule Elide.ElinkTest do
  use Elide.ModelCase

  alias Elide.{Elink, Domain}

  @valid_attrs %{domain_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Elink.changeset(%Elink{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Elink.changeset(%Elink{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "Elink.slug" do
    elink = %Elink{id: 1234}

    slug = Elink.slug(elink)
    assert slug == "e1ljd"
  end
  test "Elink.short_url" do
    elink = %Elink{id: 1234, domain: %Domain{domain: "example.net"}}

    short_url = Elink.short_url(elink)
    assert short_url == "example.net/e1ljd"
  end
end
