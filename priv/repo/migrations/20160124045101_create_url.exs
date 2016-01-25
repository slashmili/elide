defmodule Elide.Repo.Migrations.CreateUrl do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :link, :string
      add :elink_id, references(:elinks, on_delete: :nothing)

      timestamps
    end
    create index(:urls, [:elink_id])

  end
end
