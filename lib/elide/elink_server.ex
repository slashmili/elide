defmodule Elide.ElinkServer do
  use GenServer

  alias Elide.{Elink, Repo, Url}

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def create_elink(opts) do
    #TODO: validate opts
    GenServer.call(__MODULE__, {:create_elink, opts})
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
