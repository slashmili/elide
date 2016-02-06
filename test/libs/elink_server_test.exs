defmodule Elide.ElinkServerTest do
  use ExUnit.Case, async: false

  import Elide.TestHelpers

  alias Elide.{Repo, Elink, Url, ElinkServer}

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

    assert elink == fetched_elink
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

    assert elink == fetched_elink

    fetched_elink.urls
    |> List.first
    |> Url.changeset(%{link: "http://bar.com"})
    |> Repo.update

    fetch_elink_again = ElinkServer.get_elink(slug)

    cached_url = fetch_elink_again.urls |> List.first

    assert cached_url.link == foobar_dot_com ,
      "elink should be cached already and new changes in db shouldn't effect the cached value"
  end
end
