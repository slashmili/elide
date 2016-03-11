defmodule Elide.ElinkServer do
  @moduledoc """
  This module is responsible for creating and caching elinks
  """
  use GenServer

  alias Elide.{Elink, Repo, Url}
  alias Elide.RateLimiter

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, Map.new}
  end

  @doc false
  def create_elink(opts) do
    create_elink(opts, :elide_api_rate_limit)
  end

  @doc """
  Creates an elink
  """
  def create_elink(opts, api_limit_rate) do
    #TODO: validate opts
    limit_per = opts[:limit_per]
    urls = opts[:urls]
    steps = [
      fn() -> RateLimiter.check_limit!(limit_per, api_limit_rate) end,
      fn() -> has_invalid_url?(urls) end,
      fn() -> create_elink_in_db(opts) end
    ]
    perform_steps(steps)
  end

  defp perform_steps([step_fun | remaining_steps]) do
    case step_fun.() do
      {:ok} -> perform_steps(remaining_steps)
      {:ok, _} = ok -> ok
      {:error, _} = error -> error
    end
  end

  defp create_elink_in_db(opts) do
    urls = opts[:urls]
    seq = opts[:domain] |> next_seq
    elink_result =
    %Elink{
      user_id: user_id(opts),
      domain_id: opts[:domain].id,
      elink_seq: seq
    }
    |> Elink.changeset(%{})
    |> Repo.insert

    case elink_result do
      {:ok, elink} ->
        urls
        |> prepare_urls_changeset(elink.id)
        |> Enum.each(&Repo.insert!(&1))

        elink =
        elink
        |> Repo.preload(:urls)
        |> Repo.preload(:domain)
        {:ok, elink}
      {:error, changeset} ->
        {:error, [changeset]}
    end
  end

  defp user_id(opts) do
    opts[:user] && opts[:user].id || opts[:user_id]
  end

  defp next_seq(domain) do
    Elide.ElinkSeqServer.nextval(domain)
  end
  @doc """
  Gets an elink from cache or DB bsaed on slug.

  If cache is miss, it queries the database, set the cache and return the elink
  """
  def get_elink(slug) do
    case GenServer.call(__MODULE__, {:get_elink, slug}) do
      nil ->
        slug
        |> Elink.by_slug
        |> fetch_elink
        |> set_elink
      elink -> {:ok, elink}
    end
  end

  @doc """
  Adds an elink to cache
  """
  def set_elink({:error, _} = error) do
    error
  end

  def set_elink(elink) do
    GenServer.cast(__MODULE__, {:set_elink, elink})
    {:ok, elink}
  end

  defp fetch_elink({:error}) do
    {:error, :invalid_elink}
  end

  defp fetch_elink(elink) do
    case Repo.one(elink) do
      nil -> {:error, :non_existence_elink}
      elink -> elink
      |> Repo.preload(:urls)
      |> Repo.preload(:domain)
    end
  end

  def handle_call({:get_elink, slug}, _, state) do
    {:reply, Map.get(state, slug), state}
  end

  def handle_cast({:set_elink, elink}, state) do
    state = Map.put(state, Elink.slug(elink), elink)
    {:noreply, state}
  end

  defp prepare_urls_changeset(urls, elink_id \\ 0) do
    urls
    |> Enum.map(&(Url.changeset(%Url{elink_id: elink_id}, %{link: &1})))
  end

  defp has_invalid_url?(urls) do
    all_valid = urls
    |> prepare_urls_changeset
    |> Enum.all?(&(&1.valid?))
    case all_valid do
      true -> {:ok}
      _ -> {:error, prepare_urls_changeset(urls)}
    end
  end
end
