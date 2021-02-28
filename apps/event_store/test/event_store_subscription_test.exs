defmodule EventStoreSubscriptionTest do
  use ExUnit.Case, async: true
  doctest ReadWriteEventTestHelpers

  setup context do
    [streamName: StreamName.stream_name(context.test)]
  end

  test "when writing an event returns the written event", context do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: context[:streamName]})
    assert written_event.position == 0
  end

  test "when subscribe to stream expect to recieve all events", context do
    events = ReadWriteEventTestHelpers.write_events(context[:streamName], 5)
    assert 5 == Enum.count(events)
  end
end
