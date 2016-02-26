defmodule Elide.StatServerTest do
  use ExUnit.Case, async: false

  import Elide.TestHelpers

  alias Elide.{Repo, Stat, StatServer}


  setup do
    domain = insert_domain
    elink = insert_elink(domain_id: domain.id, elink_seq: 1)
    {:ok, elink: elink, domain: domain}
  end

  test "increase stat count in the same hour", %{elink: elink} do
    (1..10)
    |> Enum.each(fn(_) ->
      StatServer.inc(
        elink: elink, browser: "Chrome",
        country: "MY", referrer: "http://example.com",
        platform: "Mac", visited_at: {{2012, 10, 10},{15,40,59, 0}}
      )
    end)
    stat = Repo.get_by(Stat, %{elink_id: elink.id, tag: "browser"})

    assert stat.count == 10

  end
end

