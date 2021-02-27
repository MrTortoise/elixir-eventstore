defmodule EventStore.EventStreams.Supervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # think this becomes a supervisor that wraps all of the streams
  # do we want to add a dynamic supervisor ... at 2am i think no
  # thi sis because we want the registry adn our strategy needs changing
  # https://hexdocs.pm/elixir/DynamicSupervisor.html#content
  # look for start_child

  ###
  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec get_stream(any) :: {:error, any} | {:ok, pid} | {:ok, pid, any}
  def get_stream(stream_name) do
    case Registry.lookup(Registry.EventStreams, stream_name) do
      [] ->
        # child_spec = Supervisor.child_spec({EventStore.EventStream, [], name: name(stream_name)}, id: stream_name, shutdown: 10_000)
        # spec = %{
        #   id: stream_name,
        #   start: {EventStore.EventStream, :start_link, name: name(stream_name)}
        # }
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

  defp name(stream_name), do: {:via, Registry, {Registry.EventStreams, stream_name}}
end
