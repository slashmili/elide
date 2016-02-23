defmodule Elide.Repo.Migrations.CreateToken do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :description, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:tokens, [:user_id])

  end
end
