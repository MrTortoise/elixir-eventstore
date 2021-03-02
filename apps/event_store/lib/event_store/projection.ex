defmodule EventStore.Projection do
  use Agent, restart: :temporary

  @type t :: %EventStore.Projection{
          name: String.t(),
          predicate: fun,
          stream_name: fun
        }
  @enforce_keys [:name, :predicate, :stream_name]
  defstruct [:name, :predicate, :stream_name]

  def start_link(opts) do
    Agent.start_link(fn -> [] end, opts)
  end

  def create(%EventStore.Projection{} = projection) do
    projections = Agent.get(EventStore.Projection, & &1)

    if Enum.any?(projections, fn p -> p.name == projection.name end) do
      {:duplicate_name, projection.name}
    else
      {Agent.update(EventStore.Projection, fn s -> [projection | s] end)}
    end
  end

  def publish_event(event) do
    Agent.get(EventStore.Projection, & &1)
    |> Enum.each(fn p ->
      if(p.predicate.(event)) do
        e = %{event | position: :any, stream_name: p.stream_name.(event)}
        {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(e.stream_name)

        # we dont want to project events back into ourselves
        if(event.stream_name != e.stream_name) do
          EventStore.EventStream.write_event(pid, e)
        end
      end
    end)
  end
end
