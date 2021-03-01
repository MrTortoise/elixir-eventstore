defmodule EventStore.Projections.Supervisor do
  use Supervisor

  @moduledoc """
  Manages getting, creating and registering projections processes along with their lifecycle
  """

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {EventStore.Projection, name: EventStore.Projection}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def create(name, predicate) do
    {:ok, child} = DynamicSupervisor.start_child(__MODULE__, Supervisor.child_spec(EventStore.Projection, id: name))
    Registry.register(Registry.EventStore, name, child)
    {:ok, child}
  end

  # @spec get_stream(any) :: {:error, any} | {:ok, pid} | {:ok, pid, any}
  # def get_stream(stream_name) do
  #   case Registry.lookup(Registry.EventStore, stream_name) do
  #     [] ->
  #       {:ok, child} =
  #         DynamicSupervisor.start_child(
  #           __MODULE__,
  #           Supervisor.child_spec(EventStore.EventStream, id: stream_name)
  #         )

  #       Registry.register(Registry.EventStore, stream_name, child)
  #       {:ok, child}

  #     [{_, stream}] ->
  #       {:ok, stream}
  #   end
  # end
end
