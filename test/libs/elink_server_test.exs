defmodule Elide.ElinkServerTest do
  use ExUnit.Case, async: false

  import Elide.TestHelpers

  alias Elide.{ElinkServer}

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
end
