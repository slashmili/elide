defmodule Elide.StatServer do
  alias Elide.StatWorker

  @pool_size 2

  def start_link do
    Elide.StatPoolSupervisor.start_link(@pool_size)
  end

  def inc_elink_visit(visit_data) do
    random_worker
    |> StatWorker.inc_elink_visit(visit_data)
  end

  defp random_worker, do: :random.uniform(@pool_size)

  def browser?(user_agent) do
    cond do
      String.contains?(user_agent, "Chrome") -> "Chrome"
      String.contains?(user_agent, "Firefox") -> "Firefox"
      String.contains?(user_agent, "Safari") -> "Safari"
      String.contains?(user_agent, "Opera") -> "Opera"
      String.contains?(user_agent, "MSIE") -> "IE"
      true -> "Unknown"
    end
  end

  def country?(ip) do
    case Geolix.lookup(ip) do
      %{country: nil} -> ""
      %{country: country} -> country.country.iso_code
    end
  end

  def os?(user_agent) do
    cond do
      String.contains?(user_agent, "Windows") -> "Windows"
      String.contains?(user_agent, "Linux") -> "Linux"
      String.contains?(user_agent, "Mac") -> "Macintosh"
      true -> "Unknown"
    end
  end

  def domain?(referrer) do
    pattern = ~r/http(?:s)?:\/\/(?P<domain>(?:[\w-]+\.)*([\w-]{1,63})(?:\.(?:\w{3}|\w{2})))(?:$|\/)/i
    case Regex.named_captures(pattern, referrer) do
      %{"domain" => domain} -> domain
      _ -> ""
    end
  end
end
