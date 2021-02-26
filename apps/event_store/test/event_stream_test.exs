defmodule EventStreamTest do
  use ExUnit.Case
  doctest EventStream

  @tag :pending
  test "read a stream initialised with an event" do
    {:ok, event_stream} = EventStream.start_link([{:first_event, %Event{stream_name: "test"}}])
    {:ok, events} = EventStream.read_events(event_stream)
    assert events == [:some_event]
  end
end
