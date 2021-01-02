defmodule Phxapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Phxapp.Telemetry,
      #Start the PubSub
      {Phoenix.PubSub, name: Phxapp.PubSub},
      # Start the Endpoint (http/https)
      Phxapp.Endpoint
      # Start a worker by calling: Phxapp.Worker.start_link(arg)
      # {Phxapp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phxapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Phxapp.Endpoint.config_change(changed, removed)
    :ok
  end
end
