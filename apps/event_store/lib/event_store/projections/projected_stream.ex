defmodule EventStore.ProjectedStream do
  use Agent, restart: :temporary

  def start_link(opts) do
    Agent.start_link(fn -> %{events: [], subscriptions: [], position: -1} end, opts)
  end

  def write(projected_stream_pid, projected_event) do
    %{position: position, subscriptions: _} = Agent.get(projected_stream_pid, & &1)
    event_to_write = %{projected_event | position: position + 1}

    event_to_write
    |> write_new_event(projected_stream_pid)
    #|> publish_to_subscriptions(subscriptions)

    {:ok, event_to_write}
  end

  def read(pid) do
    %{events: events} = Agent.get(pid, & &1)
    events
  end

  defp write_new_event(event, stream_pid) do
    Agent.update(stream_pid, fn state ->
      %{
        state
        | events: [event | state.events],
          position: event.position
      }
    end)

    event
  end


  def map_to_events(events) do
    events
    |> Enum.map(fn e ->
      {:ok, stream} = EventStore.EventStreams.Supervisor.get_stream(e.stream_name)
      {:ok, event} = EventStore.EventStream.read_position(stream, e.position)
      %Event{event | is_projected: true, stream_name: e.projection_name}
    end)

  end
end
