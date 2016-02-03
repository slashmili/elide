defmodule Elide.OAuth2.Google do
  @moduledoc """
  An OAuth2 strategy for Google.
  """
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  @google_open_id_api "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
  @google_api_scope "https://www.googleapis.com/auth/userinfo.email"

  defp config do
    [strategy: __MODULE__,
     site: "https://accounts.google.com",
     authorize_url: "/o/oauth2/auth",
     token_url: "/o/oauth2/token"]
  end

  # Public API

  def client do
    Application.get_env(:elide, __MODULE__)
    |> Keyword.merge(config())
    |> OAuth2.Client.new()
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(
      client(),
      params |> Keyword.merge([scope: @google_api_scope])
      )
  end

  def get_token!(params \\ [], _headers \\ []) do
    OAuth2.Client.get_token!(client(), params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end

  def get_user_details!(token) do
    {:ok, %{body: user_details}} = OAuth2.AccessToken.get(token, @google_open_id_api)
    user_details
  end
end
