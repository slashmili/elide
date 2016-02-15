defmodule Elide.Cache.ApiRateLimitTest do
  use ExUnit.Case, async: true

  alias Elide.Cache.ApiRateLimit

  test "allow api access per ip in given time period" do
    {:ok, pid} = ApiRateLimit.start_link([
      ttl_check: :timer.seconds(1),
      ttl: :timer.seconds(5),
      api_rate_limit: 1
    ])

    assert ApiRateLimit.allowed?({127, 0, 0, 1}, pid)
    refute ApiRateLimit.allowed?({127, 0, 0, 1}, pid)

    assert ApiRateLimit.allowed?("127.0.0.2", pid)

    pid |> ApiRateLimit.stop
  end

  test "should allow access after the time period passed" do
    {:ok, pid} = ApiRateLimit.start_link([
      ttl_check: 200,
      ttl: 200,
      api_rate_limit: 2
    ])

    assert ApiRateLimit.allowed?("127.0.0.1", pid), "First access should be allowed"
    #TODO: find a better way to simulate the time movement
    :timer.sleep(100)
    assert ApiRateLimit.allowed?("127.0.0.1", pid), "Second access should be allowed"
    refute ApiRateLimit.allowed?("127.0.0.1", pid), "Third access in same time period should be denied"
    :timer.sleep(400)
    assert ApiRateLimit.allowed?("127.0.0.1", pid), "Forth access happens in new time window shoud be allowed"

    pid |> ApiRateLimit.stop
  end
end
