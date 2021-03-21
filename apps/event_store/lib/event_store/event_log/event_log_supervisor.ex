defmodule EventStore.EventLog.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {EventStore.EventLog, name: EventStore.EventLog},
      {EventStore.EventStreams.Supervisor, name: EventStore.EventStreams.Supervisor},
      {EventStore.Projections.Supervisor, name: EventStore.Projections.Supervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
