defmodule Elide.ElinkSeqServerTest do
  use ExUnit.Case, async: false

  alias Elide.ElinkSeqServer
  import Elide.TestHelpers

  setup do
    domain = insert_domain()
    {:ok, domain: domain}
  end

  test "find elink sequence for existing by checking database", %{domain: domain} do
    insert_elink(domain_id: domain.id, elink_seq: 1)
    insert_elink(domain_id: domain.id, elink_seq: 101)
    assert ElinkSeqServer.get_sequence(domain) == 101
  end

  test "find elink sequence for first elink for given domain" do
    domain = insert_domain()
    assert ElinkSeqServer.get_sequence(domain) == 0
  end
end
