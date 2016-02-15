defmodule Elide.ApiRateLimit do
  @moduledoc """
  Keep track of api usage per given key, like ip address or user id

      iex > {:ok, cache} = ApiRateLimit.start_link(
            [api_rate_limit: 2, ttl: :timer.hours(1), ttl_check: :timer.minutes(1)]
            )
      iex > ApiRateLimit.validate_limli!("127.0.0.1", cache)
      true
      iex > ApiRateLimit.validate_limli!("127.0.0.1", cache)
      true
      iex > ApiRateLimit.validate_limli!("127.0.0.1", cache)
      false

  """

  @doc """
  Creates a cache process, with capability of ttl for each cache item

  See [ConCache](https://hexdocs.pm/con_cache/) for more details.
  """
  def start_link(options, gen_server_options \\ []) do
    {:ok, pid} = ConCache.start_link(options, gen_server_options)
    rate_limit(pid, options[:api_rate_limit])
    {:ok, pid}
  end

  def start_link do
    options = [
      api_rate_limit: config[:api_rate_limit],
      ttl: :timer.hours(1),
      ttl_check: :timer.minutes(1)
    ]
    gen_server_options = [
      name: :elide_api_rate_limit
    ]
    start_link(options, gen_server_options)
  end

  defp config do
    Application.get_env(:elide, __MODULE__)
  end

  defp rate_limit(pid, limit) do
    pid
    |> ConCache.put("rate_limit_#{:elide_api_rate_limit}", %ConCache.Item{value: limit, ttl: 0})
  end

  defp rate_limit(pid) do
    pid
    |> ConCache.get("rate_limit_#{:elide_api_rate_limit}")
  end

  @doc """
  Increases the number of access
  and checkes if the given key has reached it's limit on
  """
  def validate_limit!(limitation_key, pid) do
    rate_limit(pid) >= inc(limitation_key, pid)
  end

  def validate_limit!(limitation_key) do
    validate_limit!(limitation_key, :elide_api_rate_limit)
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
