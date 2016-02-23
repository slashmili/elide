defmodule Elide.Token do
  use Elide.Web, :model

  schema "tokens" do
    field :description, :string
    belongs_to :user, Elide.User

    timestamps
  end

  @required_fields ~w(description)
  @optional_fields ~w(user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def get_key(token) do
    encode(token)
  end

  def valid?(key) do
    case decode(key) do
      {:ok, _ } -> true
      {:error, _} -> false
    end
  end

  def by_key!(key) do
    {:ok, claims} = decode(key)
    from t in __MODULE__,
      where: t.id == ^claims.id and t.user_id == ^claims.user_id
  end

  defp encode(token) do
    JsonWebToken.sign(
      %{id: token.id, user_id: token.user_id},
      %{key: secret_key}
    )
  end

  defp decode(key) do
    JsonWebToken.verify(key, %{key: secret_key})
  end

  defp secret_key do
    config = Application.get_env(:elide, Elide.Endpoint)
    config[:secret_key_base]
  end

  def by_user(user) do
    from t in __MODULE__,
      where: t.user_id == ^ user.id
  end
end
