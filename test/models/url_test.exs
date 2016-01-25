defmodule Elide.UrlTest do
  use Elide.ModelCase

  alias Elide.Url

  @valid_attrs %{link: "http://B96CB2881A1FFD98.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Url.changeset(%Url{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Url.changeset(%Url{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid link" do
    changeset = Url.changeset(%Url{}, %{link: "example.com"})
    refute changeset.valid?
  end
end
