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
end

