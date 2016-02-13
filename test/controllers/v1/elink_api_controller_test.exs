defmodule Elide.Api.V1.ElinkControllerTest do
  use Elide.ConnCase

  alias Elide.Url

  test "creates an elink through api", %{conn: conn} do
    domain = insert_domain()
    url = unique_url
    json_params = %{
      "urls" => [url]
    }
    conn = post conn, elink_api_path(conn, :create, json_params)

    assert json_response(conn, 201)
    elink_json = json_response(conn, 201)
    assert elink_json["short_url"] =~ domain.domain
    saved_url = Repo.get_by(Url, %{link: url})
    assert saved_url
  end

  test "elink creation should fail because of wrong url address", %{conn: conn} do
    insert_domain()
    url = unique_url
    json_params = %{
      "urls" => [url, "example.com"]
    }
    conn = post conn, elink_api_path(conn, :create, json_params)

    assert json_response(conn, 422)
    json = json_response(conn, 422)
    assert json == %{"errors" => [%{"example.com" => [%{"link" => "has invalid format"}]}]}
  end

  defp unique_url do
    "http://url-#{get_uniqe_id}.com"
  end
end
