defmodule Elide.TokenController do
  use Elide.Web, :controller

  alias Elide.Token

  plug :scrub_params, "token" when action in [:create, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, _user) do
    tokens = Repo.all(Token)
    render(conn, "index.html", tokens: tokens)
  end

  def new(conn, _params, _user) do
    changeset = Token.changeset(%Token{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"token" => token_params}, user) do
    changeset = Token.changeset(
      %Token{user_id: user.id},
      token_params
    )

    case Repo.insert(changeset) do
      {:ok, _token} ->
        conn
        |> put_flash(:info, "Token created successfully.")
        |> redirect(to: token_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    token = Repo.get!(Token.by_user(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(token)

    conn
    |> put_flash(:info, "Token deleted successfully.")
    |> redirect(to: token_path(conn, :index))
  end
end
