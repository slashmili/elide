defmodule Elide.Cache.ApiRateLimit do
  @moduledoc """
  Keep track of api usage per given key, like ip address or user id

      iex > {:ok, cache} = ApiRateLimit.start_link(
            [rate_limit: 2, ttl: :timer.hours(1), ttl_check: :timer.minutes(1)]
            )
      iex > ApiRateLimit.allowed?("127.0.0.1", cache)
      true
      iex > ApiRateLimit.allowed?("127.0.0.1", cache)
      true
      iex > ApiRateLimit.allowed?("127.0.0.1", cache)
      false

  """

  @doc """
  Creates a cache process, with capability of ttl for each cache item

  See [ConCache](https://hexdocs.pm/con_cache/) for more details.
  """
  def start_link(options, gen_server_options \\ []) do
    {:ok, pid} = ConCache.start_link(options, gen_server_options)
    rate_limit(pid, options[:rate_limit])
    {:ok, pid}
  end

  defp rate_limit(pid, limit) do
    pid
    |> ConCache.put("rate_limit_#{__MODULE__}", %ConCache.Item{value: limit, ttl: 0})
  end

  defp rate_limit(pid) do
    pid
    |> ConCache.get("rate_limit_#{__MODULE__}")
  end

  @doc """
  Checkes if the given key has reached it's limit on
  given period of time
  """
  def allowed?(limitation_key, pid) do
    rate_limit(pid) >= inc(limitation_key, pid)
  end

  defp inc(limitation_key, pid) do
    ConCache.update(pid, limitation_key, fn(value) ->
      case value do
        nil -> {:ok, 1}
        _   -> {:ok, %ConCache.Item{value: value + 1, ttl: :no_update}}
      end
    end)
    ConCache.get(pid, limitation_key)
  end

  @doc false
  def stop(pid) do
    pid
    |> Process.exit(:normal)
  end
end
