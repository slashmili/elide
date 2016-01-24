defmodule Elide.ElinkControllerTest do
  use Elide.ConnCase

  alias Elide.{Elink, Url}

  setup do
    user = insert_user(email: "foobar@buz.com")
    conn = assign(conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "lists all entries on index", %{conn: conn, user: _user} do
    conn = get conn, elink_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing elinks"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, elink_path(conn, :new)
    assert html_response(conn, 200) =~ "New elink"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    domain = insert_domain()
    url1 = "#{get_uniqe_id}.com"
    url2 = "#{get_uniqe_id}.com"
    urls = %{"url_1" => url1, "url_2" => url2}
    slug = "slug#{get_uniqe_id}"
    post conn, elink_path(conn, :create), elink: %{slug: slug, domain_id: domain.id}, urls: urls

    saved_url1 = Repo.get_by(Url, %{link: url1})
    assert saved_url1
    assert Repo.get_by(Url, %{link: url2})
  end

  test "creates resource with default domain", %{conn: conn} do
    insert_domain()
    url1 = "#{get_uniqe_id}.com"
    url2 = "#{get_uniqe_id}.com"
    urls = %{"url_1" => url1, "url_2" => url2}
    post conn, elink_path(conn, :create), elink: %{}, urls: urls

    saved_url1 = Repo.get_by(Url, %{link: url1})
    assert saved_url1
    assert Repo.get_by(Url, %{link: url2})
  end
end