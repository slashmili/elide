defmodule Elide.Repo.Migrations.CreateElink do
  use Ecto.Migration

  def change do
    create table(:elinks) do
      add :slug, :string
      add :domain_id, references(:domains, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :organization_id, references(:organizations, on_delete: :nothing)

      timestamps
    end
    create index(:elinks, [:domain_id])
    create index(:elinks, [:user_id])
    create index(:elinks, [:organization_id])

  end
end
