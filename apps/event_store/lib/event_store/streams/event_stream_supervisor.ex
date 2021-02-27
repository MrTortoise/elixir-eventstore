defmodule EventStore.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end
  # think this becomes a supervisor that wraps all of the streams
  # do we want to add a dynamic supervisor ... at 2am i think no
  # thi sis because we want the registry adn our strategy needs changing
  # https://hexdocs.pm/elixir/DynamicSupervisor.html#content
  # look for start_child


  ###

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: Registry.EventStreams}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def get_stream(stream_name) do
    case Registry.lookup(Registry.EventStreams, stream_name) do
      [] ->[]
    end
  end

end
