defmodule EventStore.ProjectedStream.Supervisor do
  use DynamicSupervisor

    @moduledoc """
  Manages creating projection streams
  """

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_projected_stream(projection_name) do
    case Registry.lookup(Registry.EventStore, projection_name) do
      [] ->
        {:ok, child} =
          DynamicSupervisor.start_child(
            __MODULE__,
            Supervisor.child_spec(EventStore.ProjectedStream, id: projection_name)
          )

        Registry.register(Registry.EventStore, projection_name, child)
        {:ok, child}

      [{_, stream}] ->
        {:ok, stream}
    end
  end

end
