defmodule Elide.StatServerTest do
  use ExUnit.Case, async: false

  import Elide.TestHelpers

  alias Elide.{Repo, Stat, StatServer}
  import Ecto.Query, only: [from: 2]

  setup do
    domain = insert_domain
    elink = insert_elink(domain_id: domain.id, elink_seq: 1)
    {:ok, elink: elink, domain: domain}
  end

  @tag :require_pg96
  test "use current time if visited_at is not passed", %{elink: elink} do
    visit_data = [
      elink: elink, browser: "Chrome",
      country: "MY", referrer: "http://example.com",
      platform: "Mac"
    ]
    StatServer.inc_elink_visit(visit_data)
    :timer.sleep(100)

    stat = Repo.get_by(Stat, %{elink_id: elink.id, tag: "browser"})
    assert stat.visiting_interval
  end

  test "extract client detail based on User Agent" do
    user_agent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36"
    browser = StatServer.browser?(user_agent)
    assert browser == "Chrome"

    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:43.0) Gecko/20100101 Firefox/43.0"
    browser = StatServer.browser?(user_agent)
    assert browser == "Firefox"

    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4"
    browser = StatServer.browser?(user_agent)
    assert browser == "Safari"

    user_agent = "Opera/9.80 (X11; Linux i686; Ubuntu/14.10) Presto/2.12.388 Version/12.16"
    browser = StatServer.browser?(user_agent)
    assert browser == "Opera"

    user_agent = "Mozilla/5.0 (compatible, MSIE 11, Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko"
    browser = StatServer.browser?(user_agent)
    assert browser == "IE"

    user_agent = "curl/7.9.8 (i686-pc-linux-gnu) libcurl 7.9.8 (OpenSSL 0.9.6b) (ipv6 enabled)"
    browser = StatServer.browser?(user_agent)
    assert browser == "Unknown"
  end
end
