defmodule Elide.Api.V1.ElinkControllerTest do
  use Elide.ConnCase

  alias Elide.{Url, Token, Elink}

  setup do
    domain = insert_domain()
    conn =
      Phoenix.ConnTest.conn()
      |> put_req_header("authorization", "open-access")
    {:ok, conn: conn, domain: domain}
  end

  test "creates an elink through api", %{conn: conn} do
    url = unique_url
    json_params = %{
      "urls" => [url]
    }
    conn = post conn, elink_api_path(conn, :create, json_params)

    elink_json = json_response(conn, 201)
    assert elink_json["short_url"] =~ "domain-"
    saved_url = Repo.get_by(Url, %{link: url})
    assert saved_url
  end

  test "elink creation should fail because of wrong url address", %{conn: conn} do
    url = unique_url
    json_params = %{
      "urls" => [url, "example.com"]
    }
    conn = post conn, elink_api_path(conn, :create, json_params)

    assert json_response(conn, 422)
    json = json_response(conn, 422)
    assert json == %{"errors" => [%{"example.com" => [%{"link" => "has invalid format"}]}]}
  end

  test "creates elink with specific domain", %{conn: conn} do
    expected_domain = insert_domain()
    url = unique_url
    json_params = %{
      "urls" => [url],
      "domain" => expected_domain.domain
    }
    conn = post conn, elink_api_path(conn, :create, json_params)

    assert json_response(conn, 201)
    elink_json = json_response(conn, 201)
    assert elink_json["short_url"] =~ expected_domain.domain
    saved_url = Repo.get_by(Url, %{link: url})
    assert saved_url
  end

  test "creates elink with nonexistent domain", %{conn: conn} do
    url = unique_url
    json_params = %{
      "urls" => [url],
      "domain" => "boo.com"
    }
    conn = post conn, elink_api_path(conn, :create, json_params)

    json = json_response(conn, 422)
    assert json == %{"errors" => [%{"domain" => ["domain doesn't exist"]}]}
  end

  test "calling api without authorization header should fail and shouldn't create elink" do
    domain = insert_domain
    url = unique_url
    json_params = %{
      "urls" => [url],
      "domain" => domain.domain
    }
    conn = Phoenix.ConnTest.conn()
    conn = post conn, elink_api_path(conn, :create, json_params)

    json = json_response(conn, :unauthorized)
    assert json == %{"errors" => [%{"auth" => ["invalid access"]}]}

    refute Repo.get_by(Url, %{link: url})
  end

  test "creates an elink for a user with providing auth token" do
    user = insert_user
    token = insert_token(%{user_id: user.id, description: "foo"})

    domain = insert_domain
    url = unique_url
    json_params = %{
      "urls" => [url],
      "domain" => domain.domain
    }

    conn = put_req_header(conn, "authorization", Token.get_key(token))
    conn = post conn, elink_api_path(conn, :create, json_params)

    json = json_response(conn, 201)
    %{"id" => elink_hash} = json
    elink =
      Elink.by_slug(elink_hash)
      |> Repo.one
    assert elink.user_id == user.id
  end

  test "creates an elink for a user with a removed token" do
    user = insert_user
    token = %Token{user_id: user.id, description: "foo", id: 0}

    domain = insert_domain
    url = unique_url
    json_params = %{
      "urls" => [url],
      "domain" => domain.domain
    }

    conn = put_req_header(conn, "authorization", Token.get_key(token))
    conn = post conn, elink_api_path(conn, :create, json_params)

    assert json_response(conn, 401)
  end

  defp unique_url do
    "http://url-#{get_uniqe_id}.com"
  end
end
