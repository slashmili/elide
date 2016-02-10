# Elide

[![Build Status](https://travis-ci.org/slashmili/elide.svg?branch=develop)](https://travis-ci.org/slashmili/elide)

## Development
To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`


## Test

If you have docker install, you can run test from docker

```bash
make build-img test
```

## Production

Make sure you've configured production settings in `config/prod.secret.exs`.
It should look like:

```elixir
use Mix.Config

config :elide, Elide.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "<your-domain.com>", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  server: true,
  secret_key_base: "<your secret key>"


config :elide, Elide.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "<db user in production>",
  password: "<db pass in production>",
  database: "elide_prod",
  hostname: "<db host in production>",
  pool_size: 20

config :elide, Elide.Elink,
  hashid_salt: '<salt to generate hash>'
```

And run:

```
make build-prod
```

This command creates a docker image named `elide-prod`.
You can deploy that image to your production environment.

```bash
docker run -e --rm -p 4000:4000 elide-prod
```

### DB migration on production

```
$ docker run -e --rm -p 4000:4000 elide-prod sh
$ /opt/elide/bin/elide console
iex> mig_dir = "/opt/elide/lib/elide-0.0.1/priv/repo/migrations"
iex> Ecto.Migrator.run(Elide.Repo, mig_dir, :up, [all: true])
iex> Repo.insert!(%Domain{domain: "<your-domain.com>"})
```
