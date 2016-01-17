defmodule Elide.OrganizationTest do
  use Elide.ModelCase

  alias Elide.Organization

  @valid_attrs %{name: "some content", owner_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Organization.changeset(%Organization{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with missing owner_id" do
    only_name = %{name: "name"}
    changeset = Organization.changeset(%Organization{}, only_name)
    refute changeset.valid?
  end

end
