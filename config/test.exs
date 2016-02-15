use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elide, Elide.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :elide, Elide.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "elide_test",
  hostname: "postgres-test.local",
  pool: Ecto.Adapters.SQL.Sandbox

config :elide, Elide.Elink,
  hashid_salt: ""

config :elide, Elide.Cache.ApiRateLimit,
  api_rate_limit: nil
