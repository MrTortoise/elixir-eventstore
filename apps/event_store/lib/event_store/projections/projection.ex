defmodule EventStore.Projection do
  use Agent, restart: :temporary

  @type t :: %EventStore.Projection{
          name: String.t(),
          # determines if this event should be processed by this projection
          predicate: fun,
          # derrives the stream name from the event
          stream_name: fun
        }
  @enforce_keys [:name, :predicate, :stream_name]
  defstruct [:name, :predicate, :stream_name]

  def start_link(opts) do
    event_type_projection = %EventStore.Projection{name: "event-type", predicate: fn _ -> true end, stream_name: fn e -> "et-#{e.event_type}" end}
    Agent.start_link(fn -> [event_type_projection] end, opts)
  end

  @doc """
  Adds the projection into the known list of projections
  """
  @spec create(EventStore.Projection.t()) :: {:ok} | {:duplicate_name, any}
  def create(%EventStore.Projection{} = projection) do
    projections = Agent.get(EventStore.Projection, & &1)

    if Enum.any?(projections, fn p -> p.name == projection.name end) do
      {:duplicate_name, projection.name}
    else
      {Agent.update(EventStore.Projection, fn s -> [projection | s] end)}
    end
  end

  @doc """
  If the event is already projected then do nothing (do not support projections of projections)
  """
  def project_event(%Event{is_projected: true}), do: :ok

  def project_event(event) do
    Agent.get(EventStore.Projection, & &1)
    |> Enum.each(fn p ->
      if(p.predicate.(event)) do
        projected_stream_name = p.stream_name.(event)
        pe = %EventStore.ProjectedEvent{
          projection_name: projected_stream_name,
          position: :any,
          stream_name: event.stream_name,
          stream_position: event.position
        }

        {:ok, ps} = EventStore.ProjectedStream.Supervisor.get_projected_stream(projected_stream_name)
        EventStore.ProjectedStream.write(ps, pe)

        # e = %Event{event | position: :any, stream_name: p.stream_name.(event), is_projected: true}
        # {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(e.stream_name)

        # # we dont want to project events back into ourselves
        # if(event.stream_name != e.stream_name) do
        #   {:ok, _} = EventStore.EventStream.write_event(pid, e)
        # end
      end
    end)

    :ok
  end
end
