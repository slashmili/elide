defmodule Elide.RateLimiterTest do
  use ExUnit.Case, async: true

  alias Elide.RateLimiter
  doctest RateLimiter

  test "allow api access per ip in given time period" do
    {:ok, pid} = RateLimiter.start_link([
      ttl_check: :timer.seconds(1),
      ttl: :timer.seconds(5),
      api_rate_limit: 1
    ])

    assert RateLimiter.check_limit!({127, 0, 0, 1}, pid)
    refute RateLimiter.check_limit!({127, 0, 0, 1}, pid)

    assert RateLimiter.check_limit!("127.0.0.2", pid)

    pid |> RateLimiter.stop
  end

  test "should allow access after the time period passed" do
    {:ok, pid} = RateLimiter.start_link([
      ttl_check: 200,
      ttl: 200,
      api_rate_limit: 2
    ])

    assert RateLimiter.check_limit!("127.0.0.1", pid), "First access should be allowed"
    #TODO: find a better way to simulate the time movement
    :timer.sleep(100)
    assert RateLimiter.check_limit!("127.0.0.1", pid), "Second access should be allowed"
    refute RateLimiter.check_limit!("127.0.0.1", pid), "Third access in same time period should be denied"
    :timer.sleep(400)
    assert RateLimiter.check_limit!("127.0.0.1", pid), "Forth access happens in new time window shoud be allowed"

    pid |> RateLimiter.stop
  end
end
