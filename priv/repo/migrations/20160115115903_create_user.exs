defmodule Elide.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :fullname, :string
      add :avatar, :string
      add :provider, :string
      add :uid, :string

      timestamps
    end

  end
end
