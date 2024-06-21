defmodule Bubbles.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BubblesWeb.Telemetry,
      Bubbles.Repo,
      {DNSCluster, query: Application.get_env(:bubbles, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bubbles.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Bubbles.Finch},
      # Start a worker by calling: Bubbles.Worker.start_link(arg)
      # {Bubbles.Worker, arg},
      # Start to serve requests, typically the last entry
      BubblesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bubbles.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BubblesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
