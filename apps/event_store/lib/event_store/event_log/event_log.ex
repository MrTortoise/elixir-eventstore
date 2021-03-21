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

  def read() do
    %{events: events} = Agent.get(EventStore.EventLog, & &1)
    events
  end

  def write(%Event{} = event) do
    %{events: events, position: position} = Agent.get(EventStore.EventLog, & &1)

    event_to_write = %EventStore.EventReference{
      position: position + 1,
      stream_position: event.position,
      source_stream_name: event.stream_name,
      stream_name: 'node-global'
    }

    Agent.update(EventStore.EventLog, fn _ ->
      %EventStore.EventLog{position: position + 1, events: [event_to_write | events]}
    end)

    event
  end
end
