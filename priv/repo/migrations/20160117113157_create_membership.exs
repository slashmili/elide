defmodule Elide.Repo.Migrations.CreateMembership do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :role, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :organization_id, references(:organizations, on_delete: :nothing)

      timestamps
    end
    create index(:memberships, [:user_id])
    create index(:memberships, [:organization_id])

  end
end
