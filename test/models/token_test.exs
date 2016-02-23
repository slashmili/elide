defmodule Elide.TokenTest do
  use Elide.ModelCase

  alias Elide.Token

  @valid_attrs %{description: "hello", id: 1, user_id: 1}
  @invalid_attrs %{}

  @valid_token_key "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJpZCI6MX0.Z9bXwPY5lagPr6BanFG7r10NdyMCOieikbQBq2qMbK0"
  @invalid_token_key "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJpZCI6MX0.aGVsbG8K"

  test "changeset with valid attributes" do
    changeset = Token.changeset(%Token{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Token.changeset(%Token{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "test get auth key" do
    token = %Token{user_id: 1, description: "hello", id: 1}
    assert Token.get_key(token) == @valid_token_key
  end

  test "test valide token" do
    assert Token.valid?(@valid_token_key)
  end

  test "test invalide token" do
    refute Token.valid?(@invalid_token_key)
  end

  test "search for a token by auth key" do
    #TODO: assert the query
    assert Token.by_key!(@valid_token_key)
  end

  test "search for a token with wrong auth key" do
    #TODO: assert the query
    assert catch_error(Token.by_key!(@invalid_token_key)) == {:badmatch, {:error, "invalid"}}
  end

end
