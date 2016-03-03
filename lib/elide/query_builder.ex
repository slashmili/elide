defmodule Elide.QueryBuilder do

  def upsert_stats(fields) do
    table = :stats
    unique_fields = [:elink_id, :url_id, :tag, :value, :visiting_interval]
    values = "(" <> Enum.map_join(fields, ", ", &quote_name/1) <> ") " <>
                "VALUES (" <> Enum.map_join(1..length(fields), ", ", &"$#{&1}") <> ")"
    upsert = " ON CONFLICT (#{Enum.join(unique_fields, ", ")}) DO UPDATE SET count = #{quote_table(table)}.count +1"
    "INSERT INTO #{quote_table(table)} " <> values <> upsert
  end

  defp quote_name(name) when is_atom(name), do: quote_name(Atom.to_string(name))
  defp quote_name(name) do
    if String.contains?(name, "\"") do
      raise ArgumentError, "bad field name #{inspect name}"
    end

    <<?", name::binary, ?">>
  end

  defp quote_table(name) when is_atom(name), do: quote_table(Atom.to_string(name))
  defp quote_table(name) do
    if String.contains?(name, "\"") do
      raise ArgumentError, "bad table name #{inspect name}"
    end

    <<?", String.replace(name, ".", "\".\"")::binary, ?">>
  end

end
