defmodule Elide.TestHelpers do
  alias Elide.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      fullname: "Foo Barian",
      email: "#{Base.encode16(:crypto.rand_bytes(8))}@foo.com",
      provider: "google",
      uid: Base.encode16(:crypto.rand_bytes(8))
    }, attrs)

    %Elide.User{}
    |> Elide.User.changeset(changes)
    |> Repo.insert!
  end
end

