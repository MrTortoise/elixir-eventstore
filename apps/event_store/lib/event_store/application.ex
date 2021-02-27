defmodule EventStore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: EventStore.Worker.start_link(arg)
      # {EventStore.Worker, arg}
      {Registry, keys: :unique, name: Registry.EventStreams},
      {EventStore.EventStreams.Supervisor, name: EventStore.EventStreams.Supervisor}

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EventStore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
