defmodule Elide.V1.ElinkApiController do
  use Elide.Web, :controller

  alias Elide.{Elink, Domain, ElinkServer}

  def create(conn, params) do
    urls = params["urls"]
    domain = get_domain(nil)
    elink_result = ElinkServer.create_elink(
      domain: domain,
      user: nil,
      urls: urls
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

  defp get_domain(nil) do
    [default_domain | _ ] = Repo.all(Domain)
    default_domain
  end

  defp get_domain(domain_id) do
    Repo.get!(Domain, domain_id)
  end
end
