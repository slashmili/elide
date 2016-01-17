defmodule Elide.Repo.Migrations.CreateDomain do
  use Ecto.Migration

  def change do
    create table(:domains) do
      add :domain, :string

      timestamps
    end

  end
end
