# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :phxapp,
  generators: [context_app: false]

# Configures the endpoint
config :phxapp, Phxapp.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tqdQmvS2E/sosMefyD/bLYSmH+SNoVKQtSgcQSid1ii5JNnZuBkGYNBaoPkkeZ3j",
  render_errors: [view: Phxapp.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Phxapp.PubSub,
  live_view: [signing_salt: "xhevw1mE"]

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :db, ecto_repos: [DB.Repo]
config :db, DB.Repo,
database: "tew_chat_database_2",
username: "postgres",
password: "Homerjay32!",
host: "localhost",
port: "5433"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
