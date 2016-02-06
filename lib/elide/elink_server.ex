defmodule Elide.ElinkServer do
  @moduledoc """
  This module is responsible for creating and caching elinks
  """
  use GenServer

  alias Elide.{Elink, Repo, Url}

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, Map.new}
  end

  @doc """
  Creates an elink
  """
  def create_elink(opts) do
    #TODO: validate opts
    GenServer.call(__MODULE__, {:create_elink, opts})
  end

  @doc """
  Gets an elink from cache or DB bsaed on slug.

  If cache is miss, it queries the database, set the cache and return the elink
  """
  def get_elink(slug) do
    case GenServer.call(__MODULE__, {:get_elink, slug}) do
      nil ->
        elink = fetch_elink(slug)
        set_elink(elink)
      elink -> elink
    end
  end

  @doc """
  Adds an elink to cache
  """
  def set_elink(elink) do
    GenServer.cast(__MODULE__, {:set_elink, elink})
    elink
  end

  defp fetch_elink(slug) do
    Repo.one(Elink.by_slug(slug)) |> Repo.preload(:urls)
  end

  def handle_call({:get_elink, slug}, _, state) do
    {:reply, Map.get(state, slug), state}
  end

  def handle_cast({:set_elink, elink}, state) do
    state = Map.put(state, Elink.slug(elink), elink)
    {:noreply, state}
  end

  def handle_call({:create_elink, opts}, _,state) do
    urls = opts[:urls]
    if has_invalid_url?(urls) do
      {:reply, {:error, prepare_urls_changeset(urls)}, state}
    else
      elink_result =
        %Elink{user_id: opts[:user].id, domain_id: opts[:domain].id}
        |> Elink.changeset(%{})
        |> Repo.insert

      case elink_result do
        {:ok, elink} ->
          urls
          |> prepare_urls_changeset(elink.id)
          |> Enum.map(&Repo.insert!(&1))

          elink = elink |> Repo.preload(:urls)
          {:reply, {:ok, elink}, state}
        {:error, changeset} ->
          {:reply, {:error, [changeset]}, state}
      end
    end
  end

  defp prepare_urls_changeset(urls, elink_id \\ 0) do
    urls
    |> Enum.map(&(Url.changeset(%Url{elink_id: elink_id}, %{link: &1})))
  end

  defp has_invalid_url?(urls) do
    all_valid = urls
    |> prepare_urls_changeset
    |> Enum.all?(&(&1.valid?))
    !all_valid
  end
end
