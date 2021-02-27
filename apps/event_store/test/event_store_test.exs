defmodule EventStoreTest do
  use ExUnit.Case
  doctest EventStore

  test "when writing an event returns the written event" do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event.position == 0
  end

  test "when writing a new stream the event position is 0" do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event.position == 0
  end

  test "when writing 2 events their ids are different" do
    {:ok, written_event1} = EventStore.write_event(%Event{stream_name: "testStream"})
    {:ok, written_event2} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event1.position < written_event2.position
  end
end
