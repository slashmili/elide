defmodule Elide.ElinkServerTest do
  use ExUnit.Case, async: false

  import Elide.TestHelpers

  alias Elide.{Repo, Elink, Url, ElinkServer}
  alias Elide.RateLimiter

  setup do
    user = insert_user(email: "foobar@buz.com")
    domain = insert_domain()
    {:ok, user: user, domain: domain}
  end

  test "create a new elink", %{domain: domain, user: user} do
    urls = ["http://foobar.com"]
    {:ok, elink} = ElinkServer.create_elink(
      domain: domain,
      urls: urls,
      user: user
    )
    url = elink.urls |> List.first
    assert url.link == "http://foobar.com"
    assert elink.user_id == user.id
    assert elink.domain_id == domain.id
  end

  test "shouldn't create elink since one of the urls is inavlid", %{domain: domain, user: user} do
    urls = ["wrongdomain.com", "http://foobar.com"]
    {:error, changesets} = ElinkServer.create_elink(
      domain: domain,
      urls: urls,
      user: user
    )
    wrong_url_changeset = changesets |> List.first
    assert wrong_url_changeset.errors == [link: "has invalid format"]
  end

  test "fetch an elink", %{domain: domain, user: user} do
    urls = ["http://foobar.com"]
    {:ok, elink} = ElinkServer.create_elink(
      domain: domain,
      urls: urls,
      user: user
    )

    slug = Elink.slug(elink)
    fetched_elink = ElinkServer.get_elink(slug)

    assert elink.id == fetched_elink.id
  end

  test "an already fetched elink should be cached", %{domain: domain, user: user} do
    foobar_dot_com = "http://foobar.com"
    urls = [foobar_dot_com]
    {:ok, elink} = ElinkServer.create_elink(
      domain: domain,
      urls: urls,
      user: user
    )

    slug = Elink.slug(elink)
    fetched_elink = ElinkServer.get_elink(slug)

    assert elink.id == fetched_elink.id

    fetched_elink.urls
    |> List.first
    |> Url.changeset(%{link: "http://bar.com"})
    |> Repo.update

    fetch_elink_again = ElinkServer.get_elink(slug)

    cached_url = fetch_elink_again.urls |> List.first

    assert cached_url.link == foobar_dot_com ,
      "elink should be cached already and new changes in db shouldn't effect the cached value"
  end

  test "fetch an invalid elink" do
    fetched_elink = ElinkServer.get_elink("bo")

    assert fetched_elink == {:error, :invalid_elink}
  end

  test "fetch non existence elink" do
    fetched_elink = ElinkServer.get_elink("1MtY2")

    assert fetched_elink == {:error, :non_existence_elink}
  end

  test "allow anonymous users to create elink", %{domain: domain} do
    foobar_dot_com = "http://foobar.com"
    urls = [foobar_dot_com]
    {:ok, elink} = ElinkServer.create_elink(
    domain: domain,
    urls: urls,
    user: nil
    )

    assert elink != nil
  end

  test "shouldn't allow the second Elink gets created because of Api Rate Limit", %{domain: domain} do
    {:ok, pid} = RateLimiter.start_link([
      ttl_check: :timer.seconds(5),
      ttl: :timer.seconds(20),
      api_rate_limit: 1
    ])

    foobar_dot_com = "http://foobar.com"
    urls = [foobar_dot_com]
    {:ok, elink} = ElinkServer.create_elink(
      [domain: domain, urls: urls, user: nil, limit_per: "127.0.0.1"],
      pid
    )

    assert elink != nil, "First time we should be able to create elink"

    {:error, :reached_api_rate_limit} = ElinkServer.create_elink(
      [domain: domain, urls: urls, user: nil, limit_per: "127.0.0.1"],
      pid
    )
  end
end
