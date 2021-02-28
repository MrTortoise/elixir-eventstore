defmodule EventStoreReadWriteTest do
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
    assert written_event2.position == 1
  end

  test "reading a stream gets the events back in right order" do
    {:ok, written_event1} =
      EventStore.write_event(%Event{stream_name: "testStream", data: %{"key" => "value"}})

    {:ok, written_event2} =
      EventStore.write_event(%Event{stream_name: "testStream", data: %{"key" => "value2"}})

    events = EventStore.read_stream("testStream")
    assert [written_event1, written_event2] == events
  end

  test "read an event by position" do
    streamName = "testStream"

    {:ok, written_event1} =
      EventStore.write_event(%Event{stream_name: streamName, data: %{"key" => "value3"}})

    {:ok, written_event2} =
      EventStore.write_event(%Event{stream_name: streamName, data: %{"key" => "value4"}})

    {:ok, read_event1} = EventStore.read_event(streamName, 0)
    {:ok, read_event2} = EventStore.read_event(streamName, 1)

    assert written_event1 == read_event1
    assert written_event2 == read_event2
  end

  test "read a non existant event by position returns not found" do
    streamName = "testStream"

    {:ok, written_event1} =
      EventStore.write_event(%Event{stream_name: streamName, data: %{"key" => "value3"}})

    assert {:not_found} == EventStore.read_event(streamName, 4)
  end
end
