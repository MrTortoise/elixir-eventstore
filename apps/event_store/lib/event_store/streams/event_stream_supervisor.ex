defmodule EventStore.EventStreams.Supervisor do
  use DynamicSupervisor

  @moduledoc """
  Manages getting, creating and registering event stream processes along with their lifecycle
  """

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec get_stream(any) :: {:error, any} | {:ok, pid} | {:ok, pid, any}
  def get_stream(stream_name) do
    case Registry.lookup(Registry.EventStreams, stream_name) do
      [] ->
        {:ok, child} =
          DynamicSupervisor.start_child(
            __MODULE__,
            Supervisor.child_spec(EventStore.EventStream, id: stream_name)
          )

        Registry.register(Registry.EventStreams, stream_name, child)
        {:ok, child}

      [{_, stream}] ->
        {:ok, stream}
    end
  end
end
