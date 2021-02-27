defmodule EventStreamTest do
  use ExUnit.Case
  doctest EventStore.EventStream

  @tag :pending
  test "create a stream with an event and check its position is 0" do
    {:ok, event_stream} = EventStore.EventStream.start_link([])
    {:ok, written_event} = EventStore.EventStream.write_event(event_stream, %Event{stream_name: "test"})
    assert written_event.position == 0
    assert written_event.stream_name == "test"
  end
end
