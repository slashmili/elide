defmodule Elide.Migration do
  alias Elide.{Repo, Domain}

  def migrations_path do
    Path.join [Application.app_dir(:elide) | ~w(priv repo migrations)]
  end

  def create do
    Ecto.Storage.up Repo
    update
  end

  def update do
    Ecto.Migrator.run Repo, migrations_path, :up, all: true
  end

  def create_domain(domain_name) do
    Repo.insert!(%Domain{domain: domain_name})
  end
end
