defmodule EventStoreReadWriteTest do
  use ExUnit.Case, async: true
  doctest EventStore

  setup context do
    [streamName: StreamName.stream_name(context.test)]
  end

  test "when writing an event returns the written event", context do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: context[:streamName]})
    assert written_event.position == 0
  end

  test "when writing a new stream the event position is 0", context do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: context[:streamName]})
    assert written_event.position == 0
  end

  test "when writing 2 events their ids are different", context do
    {:ok, written_event1} = EventStore.write_event(%Event{stream_name: context[:streamName]})
    {:ok, written_event2} = EventStore.write_event(%Event{stream_name: context[:streamName]})
    assert written_event1.position < written_event2.position
    assert written_event2.position == 1
  end

  test "reading a stream gets the events back in right order", context do
    {:ok, written_event1} =
      EventStore.write_event(%Event{stream_name: context[:streamName], data: %{"key" => "value"}})

    {:ok, written_event2} =
      EventStore.write_event(%Event{stream_name: context[:streamName], data: %{"key" => "value2"}})

    events = EventStore.read_stream(context[:streamName])
    assert [written_event1, written_event2] == events
  end

  test "read an event by position", context do
    streamName = context[:streamName]

    {:ok, written_event1} =
      EventStore.write_event(%Event{stream_name: streamName, data: %{"key" => "value3"}})

    {:ok, written_event2} =
      EventStore.write_event(%Event{stream_name: streamName, data: %{"key" => "value4"}})

    {:ok, read_event1} = EventStore.read_event(streamName, 0)
    {:ok, read_event2} = EventStore.read_event(streamName, 1)

    assert written_event1 == read_event1
    assert written_event2 == read_event2
  end

  test "read a non existant event by position returns not found", context do
    streamName = context[:streamName]

    {:ok, _} =
      EventStore.write_event(%Event{stream_name: streamName, data: %{"key" => "value3"}})

    assert {:not_found} == EventStore.read_event(streamName, 4)
  end
end
