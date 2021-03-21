defmodule EventStore.Projections.Supervisor do
  use Supervisor

  @moduledoc """
  Lifetime ot the Projection process
  """

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {EventStore.Projection, name: EventStore.Projection},
      {EventStore.ProjectedStream.Supervisor, name: EventStore.ProjectedStream.Supervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
