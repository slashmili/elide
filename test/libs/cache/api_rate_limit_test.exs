defmodule Elide.Cache.ApiRateLimitTest do
  use ExUnit.Case, async: true

  alias Elide.Cache.ApiRateLimit

  test "allow api access per ip in given time period" do
    {:ok, pid} = ApiRateLimit.start_link([
      ttl_check: :timer.seconds(1),
      ttl: :timer.seconds(5),
      rate_limit: 1
    ])

    assert ApiRateLimit.allowed?("127.0.0.1", pid)
    refute ApiRateLimit.allowed?("127.0.0.1", pid)

    assert ApiRateLimit.allowed?("127.0.0.2", pid)

    ApiRateLimit.stop(pid)
  end

  test "should allow access after the time period passed" do
    {:ok, pid} = ApiRateLimit.start_link([
      ttl_check: :timer.seconds(1),
      ttl: :timer.seconds(1),
      rate_limit: 1
    ])

    assert ApiRateLimit.allowed?("127.0.0.1", pid)
    #TODO: find a better way to simulate the time movment
    :timer.sleep(1000)
    assert ApiRateLimit.allowed?("127.0.0.1", pid)
  end
end
