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
      {Registry, keys: :unique, name: Registry.EventStore},
      {EventStore.EventStreams.Supervisor, name: EventStore.EventStreams.Supervisor},
      {EventStore.Projections.Supervisor, name: EventStore.Projections.Supervisor}
    ]

    # when something fails all items after in children will restart.
    # when registry dies atm eveything is dead
    opts = [strategy: :rest_for_one, name: EventStore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
