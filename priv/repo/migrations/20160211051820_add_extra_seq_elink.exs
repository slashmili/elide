defmodule Elide.Repo.Migrations.AddExtraSeqElink do
  use Ecto.Migration

  def change do
    alter table(:elinks) do
      add :elink_seq, :integer, null: false
    end
    create unique_index(:elinks, [:elink_seq, :domain_id])
  end
end
