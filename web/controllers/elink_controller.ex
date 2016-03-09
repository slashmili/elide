defmodule Elide.ElinkController do
  use Elide.Web, :controller

  alias Elide.{Elink, Url, Domain, ElinkServer}

  plug :scrub_params, "elink" when action in [:update]

  def index(conn, _params) do
    changeset = Elink.changeset(%Elink{})
    elinks =
      Elink
      |> Repo.all
      |> Repo.preload(:domain)
      |> Repo.preload(:urls)
      |> Repo.preload(:organization)
    render(conn, "index.html", elinks: elinks, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Elink.changeset(%Elink{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"elink" => elink_params, "urls" => urls}) do
    user = conn.assigns[:current_user]

    domain = get_domain(elink_params["domain_id"])
    elink_result = ElinkServer.create_elink(
      domain: domain,
      user: user,
      urls: urls |> Map.values,
      limit_per: conn.remote_ip
    )

    case elink_result do
      {:ok, _elink} ->
        conn
        |> put_flash(:info, "Elink created successfully.")
        |> redirect(to: elink_path(conn, :index))
      {:error, _changesets} ->
        #TODO: handle showing error from list of changeset
        throw :not_implemented
    end
  end

  def go(conn, %{"slug" => slug}) do
    slug
    |> ElinkServer.get_elink
    |> redirect_to_url(conn)
  end

  defp redirect_to_url({:error, _}, conn) do
    conn
    |> put_status(404)
    |> render(Elide.ErrorView, "404.html")
    |> halt
  end

  defp redirect_to_url(elink, conn) do
    url = elink.urls |> Enum.shuffle |> List.first
    conn
    |> inc_stat(elink)
    |> redirect(external: url.link)
    |> halt
  end

  defp inc_stat(conn, elink) do
    browser =
      conn
      |> get_header("user-agent")
      |> Elide.StatServer.browser?

    os =
      conn
      |> get_header("user-agent")
      |> Elide.StatServer.os?

    referrer =
      conn
      |> get_header("referrer")
      |> Elide.StatServer.domain?

    visit_data = [
      elink: elink, browser: browser,
      country: Elide.StatServer.country?(conn.remote_ip), referrer: referrer,
      platform: os
    ]
    Elide.StatServer.inc_elink_visit(visit_data)

    conn
  end

  defp get_header(conn, key) do
    header_tuple =
      conn.req_headers
      |> Enum.filter(&elem(&1, 0) == key)
      |> List.first
      case header_tuple do
        nil -> ""
        {key, value} -> value
      end
  end

  defp get_domain(nil) do
    [default_domain | _] = Repo.all(Domain)
    default_domain
  end

  defp get_domain(domain_id) do
    Repo.get!(Domain, domain_id)
  end

  def create_url(elink, url) do
    {_, link} = url
    changeset =
      elink
      |> build_assoc(:urls)
      |> Url.changeset(%{link: link})
    {:ok, _url} = Repo.insert(changeset)
  end
end
