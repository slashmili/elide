defmodule Elide.StatServer do
  use Timex

  def inc_elink_visit(opts) do
    visiting_interval =
      opts[:visited_at]
      |> reset_hour
      |> to_tuple

    Elide.Stat.get_tags
    |> Enum.map(&String.to_atom(&1))
    |> Enum.filter(&(opts[&1] != nil))
    |> Enum.each(fn(tag) ->
      inc_elink_stat_by_tag(opts[:elink], tag, opts[tag], visiting_interval)
    end)
  end

  defp inc_elink_stat_by_tag(elink, tag, value, visiting_interval) do
    created_at =
      Date.now
      |> to_tuple

    data = %{
      elink_id: elink.id, tag: Atom.to_string(tag),
      value: value, visiting_interval: visiting_interval,
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
