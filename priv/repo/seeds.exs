# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

#Added default domain
Elide.Repo.insert!(%Elide.Domain{domain: "localhost:4000"})
