defmodule Elide.StatWorkerTest do
  use ExUnit.Case, async: false

  import Elide.TestHelpers

  alias Elide.{Repo, Stat, StatWorker}
  import Ecto.Query, only: [from: 2]

  @worker_id 100

  setup do
    domain = insert_domain
    elink = insert_elink(domain_id: domain.id, elink_seq: 1)
    url = insert_url(elink_id: elink.id, link: "http://#{get_uniqe_id}.com")
    {:ok, _} = StatWorker.start_link(@worker_id)
    {:ok, elink: elink, domain: domain, url: url}
  end

  @tag :require_pg96
  test "save visiting interval by trimming min, sec and ms", %{elink: elink} do
    date = Timex.Date.from({{2012, 10, 10}, {15, 40, 59, 0}})

    visit_data = [
      elink: elink, browser: "Chrome",
      country: "MY", referrer: "http://example.com",
      platform: "Mac", visited_at: date
    ]
    StatWorker.inc_elink_visit(@worker_id, visit_data)

    StatWorker.noop(@worker_id)
    stat = Repo.get_by(Stat, %{elink_id: elink.id, tag: "browser"})
    assert stat.visiting_interval == Timex.Date.from({{2012, 10, 10}, {15, 0, 0, 0}})
  end

  @tag :require_pg96
  test "use current time iv visited_at is not passed", %{elink: elink} do
    visit_data = [
      elink: elink, browser: "Chrome",
      country: "MY", referrer: "http://example.com",
      platform: "Mac"
    ]
    StatWorker.inc_elink_visit(@worker_id, visit_data)

    StatWorker.noop(@worker_id)
    stat = Repo.get_by(Stat, %{elink_id: elink.id, tag: "browser"})
    assert stat.visiting_interval
  end

  @tag :require_pg96
  test "increasing stat should create 4 records", %{elink: elink} do
    date = Timex.Date.from({{2012, 10, 10}, {15, 40, 59, 0}})
    visit_data = [
      elink: elink, browser: "Chrome",
      country: "MY", referrer: "http://example.com",
      platform: "Mac", visited_at: date
    ]
    StatWorker.inc_elink_visit(@worker_id, visit_data)

    StatWorker.noop(@worker_id)

    elink_id = elink.id
    q = from s in Stat, where: s.elink_id == ^elink_id
    stat = Repo.all(q)
    assert Enum.count(stat) == 4
  end

  @tag :require_pg96
  test "increase stat count in the same hour", %{elink: elink, url: url} do
    (1..10)
    |> Enum.each(fn(i) ->
      date = Timex.Date.from({{2013, 11, 1}, {11, 30, i, 7}})
      visit_data = [
        elink: elink, url: url,
        browser: "Chrome", country: "MY",
        referrer: "http://example.com",
        platform: "Mac", visited_at: date
      ]
      StatWorker.inc_elink_visit(@worker_id, visit_data)
    end)
    StatWorker.noop(@worker_id)

    stat = Repo.get_by(Stat, %{elink_id: elink.id, tag: "browser"})

    assert stat.count == 10
  end
end
