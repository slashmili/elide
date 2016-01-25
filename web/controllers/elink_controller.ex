defmodule Elide.ElinkController do
  use Elide.Web, :controller

  alias Elide.{Elink, Url, Domain}

  plug :scrub_params, "elink" when action in [:update]

  def index(conn, _params) do
    elinks = Repo.all(Elink) |> Repo.preload(:domain)
    render(conn, "index.html", elinks: elinks)
  end

  def new(conn, _params) do
    changeset = Elink.changeset(%Elink{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"elink" => elink_params, "urls" => urls}) do
    user = conn.assigns[:current_user]

    domain = get_domain(elink_params["domain_id"])
    changeset = Elink.changeset(%Elink{user_id: user.id, domain_id: domain.id}, elink_params)
    {:ok, elink} = Repo.insert(changeset)


    #TODO: handle failures
    Enum.each(urls, &create_url(elink, &1))

    conn
    |> put_flash(:info, "Elink created successfully.")
    |> redirect(to: elink_path(conn, :index))
  end

  defp get_domain(nil) do
    [default_domain | _ ] = Repo.all(Domain)
    default_domain
  end

  defp get_domain(domain_id) do
    Repo.get!(Domain, domain_id)
  end

  def create_url(elink, url) do
    {_, link} = url
    changeset = build_assoc(elink, :urls, %{link: link})
    {:ok, _url} = Repo.insert(changeset)
  end
end
