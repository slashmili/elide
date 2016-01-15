defmodule Elide.AuthController do
  use Elide.Web, :controller
  alias Elide.OAuth2.Google
  alias Elide.User

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  defp authorize_url!("google"),   do: Google.authorize_url!(scope: "https://www.googleapis.com/auth/userinfo.email")
  defp authorize_url!(_), do: raise "No matching provider available"

  defp get_token!("google", code),   do: Google.get_token!(code: code)

  defp get_user!("google", token) do
    #TODO: handle in case of error like
    #%{"error" => %{"code" => 401,
    #"errors" => [%{"domain" => "global", "location" => "Authorization",
    #"locationType" => "header", "message" => "Invalid Credentials",
    #"reason" => "authError"}], "message" => "Invalid Credentials"}}

    {:ok, %{body: user}} = OAuth2.AccessToken.get(token, "https://www.googleapis.com/plus/v1/people/me/openIdConnect")
    first_or_create(
      user["email"],
      user["sub"],
      "google",
      user["given_name"] <> user["family_name"],
      user["picture"]
    )
  end

  defp first_or_create(email, uid, provider, fullname, avatar) do
    case Repo.get_by(User, %{email: email, uid: uid, provider: provider}) do
      nil ->
        {ok, user} = Repo.insert(%User{email: email, uid: uid, provider: provider, fullname: fullname, avatar: avatar})
        user
      user -> user
    end
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    token = get_token!(provider, code)

    user = get_user!(provider, token)

    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, token.access_token)
    |> redirect(to: "/")
  end

end
