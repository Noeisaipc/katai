defmodule Katai.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Katai.Repo,
      # Start the Telemetry supervisor
      KataiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Katai.PubSub},
      # Start the Endpoint (http/https)
      KataiWeb.Endpoint
      # Start a worker by calling: Katai.Worker.start_link(arg)
      # {Katai.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Katai.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    KataiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
