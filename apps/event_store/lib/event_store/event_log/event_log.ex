defmodule EventStore.EventLog do
  use Agent, restart: :temporary

  defstruct position: -1, events: []

  @type t() :: %__MODULE__{
          position: non_neg_integer(),
          events: [EventStore.EventReference]
        }

  def start_link(opts) do
    Agent.start_link(fn -> %EventStore.EventLog{} end, opts)
  end

  @doc """
  currently reads all events in the event log (they will come out reversed)
  """
  def read() do
    %{events: events} = Agent.get(EventStore.EventLog, & &1)
    events
  end

  @doc """
  writes an event into the event log - this points directly at an event in a stream
  """
  def write(%Event{} = event) do
    %{events: events, position: position} = Agent.get(EventStore.EventLog, & &1)

    event_to_write = %EventStore.EventReference{
      position: position + 1,
      stream_position: event.position,
      source_stream_name: event.stream_name,
      stream_name: 'node-global', # starting to think about how ordering might work with multiple nodes
      is_projected: false
    }

    Agent.update(EventStore.EventLog, fn _ ->
      %EventStore.EventLog{position: position + 1, events: [event_to_write | events]}
    end)

    event
  end
end
