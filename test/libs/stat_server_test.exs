defmodule Elide.StatServerTest do
  use ExUnit.Case, async: false

  import Elide.TestHelpers

  alias Elide.{Repo, Stat, StatServer}


  setup do
    domain = insert_domain
    elink = insert_elink(domain_id: domain.id, elink_seq: 1)
    {:ok, elink: elink, domain: domain}
  end

  test "save visiting interval by trimming min, sec and ms", %{elink: elink} do
    date = Timex.Date.from({{2012, 10, 10}, {15, 40, 59, 0}})
    StatServer.inc(
    elink: elink, browser: "Chrome",
    country: "MY", referrer: "http://example.com",
    platform: "Mac", visited_at: date
    )

    stat = Repo.get_by(Stat, %{elink_id: elink.id, tag: "browser"})
    assert stat.visiting_interval == Timex.Date.from({{2012, 10, 10}, {15, 0, 0, 0}})
  end

  test "increase stat count in the same hour", %{elink: elink} do
    (1..10)
    |> Enum.each(fn(_) ->
      date = Timex.Date.from({{2013, 11, 1}, {11, 30, 59, 7}})
      StatServer.inc(
        elink: elink, browser: "Chrome",
        country: "MY", referrer: "http://example.com",
        platform: "Mac", visited_at: date
      )
    end)
    stat = Repo.get_by(Stat, %{elink_id: elink.id, tag: "browser"})

    assert stat.count == 10

  end
end

