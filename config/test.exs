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
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :elide, Elide.OAuth2.Google,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")
