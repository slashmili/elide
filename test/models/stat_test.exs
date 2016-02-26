defmodule Elide.StatTest do
  use Elide.ModelCase

  alias Elide.Stat

  @valid_attrs %{elink_id: 1, count: 42, tag: "browser", value: "some content", visited_at: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Stat.changeset(%Stat{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with valid tags" do
    ["browser", "referrer", "country", "platform"]
    |> Enum.each(fn(t) ->
      valid_attrs = Map.put(@valid_attrs, :tag, t)
      changeset = Stat.changeset(%Stat{}, valid_attrs)
      assert changeset.valid?, "tag `#{t}` should be valid"
    end)
  end

  test "changeset with invalid tag" do
    invalid_attrs = Map.put(@valid_attrs, :tag, "foo")
    changeset = Stat.changeset(%Stat{}, invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Stat.changeset(%Stat{}, @invalid_attrs)
    refute changeset.valid?
  end
end
