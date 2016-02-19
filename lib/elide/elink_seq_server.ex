defmodule Elide.ElinkSeqServer do
  @moduledoc """
    Provides elink sequence for given domain

    The idea is to keep the elinks as short as possible by creating
    elink hash per domain. This module is responsible to provide unique
    hash per domain

    > It's not safe to use this module in distributed environment
  """

  import Ecto.Query, only: [from: 1, from: 2]
  alias Elide.{Repo, Elink}

  @doc false
  def start_link() do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def nextval(domain_id) when is_integer(domain_id) do
    Agent.get_and_update(__MODULE__, fn(state) ->
      seq = case Map.get(state, domain_id) do
        nil -> get_sequence(domain_id)
        seq -> seq
      end
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

  @doc false
  def get_sequence(domain_id) when is_integer(domain_id)  do
    last_seq_query = from e in Elink, select: max(e.elink_seq),  where: e.domain_id == ^domain_id
    seq = Repo.one(last_seq_query) || 0
  end

  @doc """
  Gets the last used sequence for given domain
  """
  def get_sequence(domain) do
    get_sequence(domain.id)
  end
end
