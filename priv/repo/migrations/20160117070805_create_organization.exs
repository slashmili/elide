defmodule Elide.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:organizations, [:owner_id])

  end
end
