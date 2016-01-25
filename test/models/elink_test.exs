defmodule Elide.ElinkTest do
  use Elide.ModelCase

  alias Elide.Elink

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
end
