defmodule Elide.MembershipTest do
  use Elide.ModelCase

  alias Elide.Membership

  @valid_attrs %{role: "m", user_id: 1, organization_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Membership.changeset(%Membership{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Membership.changeset(%Membership{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with missing user_id" do
    invalid_attrs = Map.delete @valid_attrs, :user_id
    changeset = Membership.changeset(%Membership{}, invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with missing organization_id" do
    invalid_attrs = Map.delete @valid_attrs, :organization_id
    changeset = Membership.changeset(%Membership{}, invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid role" do
    invalid_attrs = Map.put @valid_attrs, :role, "foo"
    changeset = Membership.changeset(%Membership{}, invalid_attrs)
    refute changeset.valid?
  end
end
