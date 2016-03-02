defmodule Elide.StatWorker do
  use GenServer
  use Timex

  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(worker_id))
  end

  defp via_tuple(worker_id) do
    {:via, :gproc, {:n, :l, {:stat_worker, worker_id}}}
  end

  def inc_elink_visit(worker_id, opts) do
    opts = Keyword.update(opts, :visited_at, Date.now, fn(visited_at) -> visited_at end)
    GenServer.cast(via_tuple(worker_id), {:inc_elink_visit, opts})
  end

  def noop(worker_id) do
    GenServer.call(via_tuple(worker_id), {:noop})
  end

  def handle_cast({:inc_elink_visit, opts}, state) do
    visiting_interval =
      opts[:visited_at]
      |> reset_hour
      |> to_tuple

    Elide.Stat.get_tags
    |> Enum.map(&String.to_atom(&1))
    |> Enum.filter(&(opts[&1] != nil))
    |> Enum.each(fn(tag) ->
      inc_elink_stat_by_tag(opts[:elink], opts[:url], tag, opts[tag], visiting_interval)
    end)
    {:noreply, state}
  end

  def handle_call({:noop}, _, state), do: {:reply, :noop, state}

  defp inc_elink_stat_by_tag(elink, url, tag, value, visiting_interval) do
    created_at =
      Date.now
      |> to_tuple

    data = %{
      elink_id: elink.id, url_id: url && url.id,
      tag: Atom.to_string(tag), value: value,
      visiting_interval: visiting_interval,
      inserted_at: created_at, updated_at: created_at,
      count: 1
    }

    query = Elide.QueryBuilder.upsert_stats(Map.keys(data))
    {:ok, _} = Ecto.Adapters.SQL.query(Elide.Repo, query, Map.values(data))
  end

  defp to_tuple(%DateTime{} = date) do
    %DateTime{year: y, month: m, day: d, hour: h, minute: min, second: s, ms: ms} = date
    {{y, m, d}, {h, min, s, round(ms * 1_000)}}
  end

  defp reset_hour(%DateTime{} = date) do
    date
    |> Map.put(:minute, 0)
    |> Map.put(:second, 0)
    |> Map.put(:ms, 0)
  end
end
