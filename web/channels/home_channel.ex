defmodule Elide.HomeChannel do
  use Elide.Web, :channel

  alias Elide.{ElinkServer, Repo, Elink, Domain}

  def join("home:" <> home_id, _params, socket) do
    #:timer.send_interval(5_000, :ping)
    {:ok, assign(socket, :home_id, home_id)}
  end

  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push socket, "ping", %{count: count}

    {:noreply, assign(socket, :count, count + 1)}
  end

  def handle_in("create_elink", params, socket) do
    domain = get_domain()
    elink = ElinkServer.create_elink(
      domain: domain,
      user: nil,
      urls: [params["url"]]
    )
    elink |> create_elink_response(socket)
  end

  defp create_elink_response({:ok, elink}, socket) do
    {:ok, elink} =
      elink
      |> Elink.slug
      |> ElinkServer.get_elink
    push socket, "create_elink", %{slug: Elink.short_url(elink)}
    {:reply, :ok, socket}
  end

  defp create_elink_response({:error, _changesets}, socket) do
    #TODO: find the error from changesets
    #error = changesets |> List.first | Map.get
    error = "wrong url format"
    push socket, "create_elink", %{error: error}
    {:reply, :error, socket}
  end

  defp get_domain() do
    [default_domain | _] = Repo.all(Domain)
    default_domain
  end

end
