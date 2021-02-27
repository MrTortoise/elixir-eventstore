defmodule EventStoreTest do
  use ExUnit.Case
  doctest EventStore

  test "when writing an event returns the written event" do
    {:ok, written_event, _} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event.position == 0
  end

  test "when writing a new stream the event position is 0" do
    {:ok, written_event, _} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event.position == 0
  end

  @tag :temporary
  test "EventStore returns the pid of the eventstream on write" do
    {:ok, _, pid} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert pid != nil
  end

  test "when writing 2 events their ids are different" do
    {:ok, written_event1, _} = EventStore.write_event(%Event{stream_name: "testStream"})
    {:ok, written_event2, _} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event1.position < written_event2.position
  end
end
