defmodule Elide.StatServer do
  def inc(opts) do
    data = %{
      country: opts[:country], platform: opts[:platform],
      elink_id: opts[:elink].id, browser: opts[:browser],
      referrer: opts[:referrer], visiting_interval: opts[:visited_at]
    }
    data = %{
      elink_id: opts[:elink].id, tag: "browser",
      value: opts[:browser], visiting_interval: opts[:visited_at],
      inserted_at: {{2012, 10, 10},{15,40,59, 0}}, updated_at: {{2012, 10, 10},{15,40,59, 0}},
      count: 1
    }
    query = Elide.QueryBuilder.upsert_stats(Map.keys(data))
    {:ok, _} = Ecto.Adapters.SQL.query(Elide.Repo, query, Map.values(data))
  end
end
