# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :fgc,
  ecto_repos: [Fgc.Repo]

# Configures the endpoint
config :fgc, FgcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ThxnCH1HB1hyKBX8TuAkBc8VEezct/dKWP5QFPKJLFKOTEgS/sn32rHFgdSLHTDx",
  render_errors: [view: FgcWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Fgc.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :fgc, Fgc.UserManager.Guardian,
  issuer: "fgc",

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
