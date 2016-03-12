defmodule Elide.V1.ElinkApiController do
  @moduledoc """
  API interface to Elide's shorten url service
  """

  use Elide.Web, :controller

  alias Elide.{Elink, Domain, ElinkServer, Token}

  def create(conn, %{"urls" => urls, "domain" => domain_addr}) do
    domain =
      domain_addr
      |> Domain.by_address
      |> Repo.one

    conn
    |> auth
    |> create_elink(urls, domain)
  end

  def create(conn, %{"urls" => urls}) do
    domain =
      Domain.default_domain
      |> Repo.one

    conn
    |> auth
    |> create_elink(urls, domain)
  end

  defp auth(conn) do
    auth_header =
      conn.req_headers
      |> Enum.filter(&elem(&1, 0) == "authorization")
    cond do
      Enum.count(auth_header) == 0 -> put_status(conn, :unauthorized)
      {"authorization", "open-access"} == hd(auth_header) -> conn
      {"authorization", auth_token} = hd(auth_header) ->
        if Token.valid?(auth_token) do
          case Repo.one(Token.by_key!(auth_token)) do
            nil -> put_status(conn, :unauthorized)
            token -> assign(conn, :user_id, token.user_id)
          end
        else
          put_status(conn, :unauthorized)
        end
    end
  end

  def create_elink(conn = %Plug.Conn{status: 401}, _urls, _domain) do
    conn
    |> render("error.json", errors: [%{"auth" => ["invalid access"]}])
  end

  def create_elink(conn, _urls, nil) do
    conn
    |> put_status(:unprocessable_entity)
    |> render("error.json", errors: [%{"domain" => ["domain doesn't exist"]}])
  end

  def create_elink(conn, urls, domain) do
    elink_result = ElinkServer.create_elink(
      domain: domain,
      urls: urls,
      user_id: conn.assigns[:user_id],
      limit_per: conn.remote_ip
    )

    case elink_result do
      {:ok, elink} ->
        elink_json = %{
          short_url: Elink.short_url(elink),
          id: Elink.slug(elink)
        }
        conn
        |> put_status(:created)
        |> render("show.json", elink: elink_json)
      {:error, :reached_api_rate_limit} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", errors: [%{"api" => ["Reached max api usage, retry in an hour"]}])
      {:error, changesets} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", errors: export_errors(changesets))
    end
  end

  defp export_errors(changesets) do
    changesets
    |> Enum.filter(fn(e) -> !e.valid? end)
    |> Enum.map(fn(e) -> %{e.changes[:link] => to_list_of_map(e.errors)} end)
  end

  defp to_list_of_map(keyword_list) do
    keyword_list
    |> Enum.map(fn({k,v}) -> %{k => v} end)
  end
end
