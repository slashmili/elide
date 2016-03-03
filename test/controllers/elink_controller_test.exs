defmodule Elide.ElinkControllerTest do
  use Elide.ConnCase

  alias Elide.{Elink, Url}

  setup do
    user = insert_user(email: "foobar@buz.com")
    conn = assign(conn(), :current_user, user)
    domain = insert_domain()
    {:ok, conn: conn, user: user, domain: domain}
  end

  test "lists all entries on index", %{conn: conn, user: _user} do
    conn = get conn, elink_path(conn, :index)
    assert html_response(conn, 200) =~ "Your Links"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, elink_path(conn, :new)
    assert html_response(conn, 200) =~ "New Elink"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, domain: domain} do
    url1 = "http://#{get_uniqe_id}.com"
    url2 = "http://#{get_uniqe_id}.com"
    urls = %{"url_1" => url1, "url_2" => url2}
    slug = "slug#{get_uniqe_id}"
    post conn, elink_path(conn, :create), elink: %{slug: slug, domain_id: domain.id}, urls: urls

    saved_url1 = Repo.get_by(Url, %{link: url1})
    assert saved_url1
    assert Repo.get_by(Url, %{link: url2})
  end

  test "creates resource with default domain", %{conn: conn} do
    url1 = "http://#{get_uniqe_id}.com"
    url2 = "http://#{get_uniqe_id}.com"
    urls = %{"url_1" => url1, "url_2" => url2}
    post conn, elink_path(conn, :create), elink: %{}, urls: urls

    saved_url1 = Repo.get_by(Url, %{link: url1})
    assert saved_url1
    assert Repo.get_by(Url, %{link: url2})
  end

  @tag :require_pg96
  test "create elink and visit short url", %{conn: conn} do
    url1 = "http://#{get_uniqe_id}.com"
    urls = %{"url_1" => url1}

    post conn, elink_path(conn, :create), elink: %{}, urls: urls

    saved_url1 = Repo.get_by(Url, %{link: url1}) |> Repo.preload(:elink)


    conn = put_req_header(conn, "user-agent", "phoenix test")
    slug = Elink.slug(saved_url1.elink)
    conn = get conn, elink_path(conn, :go, slug)
    :timer.sleep(10)

    assert get_resp_header(conn, "location") == [url1]
    assert conn.halted
  end
end
