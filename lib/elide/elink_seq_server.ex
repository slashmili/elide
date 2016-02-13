defmodule Elide.ElinkSeqServer do
  @moduledoc """
    Provides elink sequence for given domain

    The idea is to keep the elinks as short as possible by creating
    elink hash per domain. This module is responsible to provide unique
    hash per domain

    > It's not safe to use this module in distributed environment
  """

  import Ecto.Query, only: [from: 1, from: 2]
  alias Elide.{Repo, Elink, Domain}

  @doc """
  Initialize ElinkSeqServer state
  """
  def init do
    Repo.all(Domain)
    |> Enum.map(fn(d) -> {d.id, get_sequence(d)} end)
    |> Enum.into(%{})
  end

  @doc false
  def start_link() do
    Agent.start_link(fn -> init end, name: __MODULE__)
  end

  def nextval(domain_id) when is_integer(domain_id) do
    Agent.get_and_update(__MODULE__, fn(state) ->
      seq = Map.get state, domain_id, 0
      state = Map.put state, domain_id, seq + 1
      {seq + 1, state}
    end)
  end

  @doc """
  Returns the next sequence id for given domain_id

      iex> Elide.ElinkSeqServer.nextval(20)
      1
      iex> Elide.ElinkSeqServer.nextval(20)
      2

  Returns the next sequence id for given domain
      iex> domain = %Elide.Domain{id: 12}
      iex> Elide.ElinkSeqServer.nextval(domain)
      1
      iex> Elide.ElinkSeqServer.nextval(domain)
      2

  """
  def nextval(domain) do
    nextval(domain.id)
  end

  @doc """
  Gets the last used sequence for given domain
  """
  def get_sequence(domain) do
    domain_id = domain.id
    last_seq_query = from e in Elink, select: max(e.elink_seq),  where: e.domain_id == ^domain_id
    seq =
      last_seq_query
      |> Repo.one
    seq || 1
  end
end
