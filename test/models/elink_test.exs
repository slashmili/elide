defmodule Elide.ElinkTest do
  use Elide.ModelCase

  alias Elide.{Elink, Domain}

  @valid_attrs %{domain_id: 1, elink_seq: 10}
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
    elink = %Elink{id: 1234, domain_id: 1, elink_seq: 10}

    slug = Elink.slug(elink)
    assert slug == "wpfg"
  end

  test "Elink.short_url" do
    elink = %Elink{id: 1234, domain: %Domain{domain: "example.net"}, domain_id: 1, elink_seq: 10}

    short_url = Elink.short_url(elink)
    assert short_url == "example.net/wpfg"
  end

  test "Get elink details by providing slug" do
    details = Elink.get_details_by_slug("wpfg")
    assert details[:domain_id] == 1
    assert details[:elink_seq] == 10
  end
end
