defmodule EventStreamTest do
  use ExUnit.Case, async: true
  doctest EventStore.EventStream

  setup context do
    [streamName: StreamName.stream_name(context.test)]
  end

  test "create a stream with an event and check its position is 0", context do
    {:ok, event_stream} = EventStore.EventStream.start_link([])
    {:ok, written_event} = EventStore.EventStream.write_event(event_stream, %Event{stream_name: context[:streamName], data: %{}, position: :any})
    assert written_event.position == 0
    assert written_event.stream_name ==  context[:streamName]
  end
end
