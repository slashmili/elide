defmodule Elide.DomainTest do
  use Elide.ModelCase

  alias Elide.Domain

  @valid_attrs %{domain: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Domain.changeset(%Domain{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Domain.changeset(%Domain{}, @invalid_attrs)
    refute changeset.valid?
  end
end
