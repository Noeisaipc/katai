# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :katai,
  ecto_repos: [Katai.Repo]

# Configures the endpoint
config :katai, KataiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fyUOmwCAqbti/a41frO9SmN6rY2kWPRcpdGPP7DYd5g7hT2WsZBgS8IMrgq/q8qO",
  render_errors: [view: KataiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Katai.PubSub,
  live_view: [signing_salt: "9LM8688M"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :katai, KataiWeb.Guardian,
       issuer: "katai",
       secret_key: "Zn4WTour4LiNL8SG7GFvRPfhATLkXLfbmuyIzQBotzOZ48vx2vF6cciIDtJJOHHg"
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
