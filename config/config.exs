# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :todo_app,
  ecto_repos: [TodoApp.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :todo_app, TodoAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TodoAppWeb.ErrorHTML, json: TodoAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TodoApp.PubSub,
  live_view: [signing_salt: "ktQjf845"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :todo_app, TodoApp.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

# Подключение к Базе Данных в dev-режиме (через Docker)
config :todo_app, TodoApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "db",          # ← Docker-сервис из docker-compose.yml
  database: "todo_app_dev",
  port: 5432,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10 #Это нечто


import_config "#{config_env()}.exs"
