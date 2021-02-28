defmodule EventStoreSubscriptionTest do
  use ExUnit.Case, async: true
  doctest ReadWriteEventTestHelpers

  setup context do
    [stream_name: StreamName.stream_name(context.test)]
  end

  test "when writing an event returns the written event", context do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: context[:stream_name]})
    assert written_event.position == 0
  end

  test "when subscribe to stream expect to recieve all events", context do
    streamName = context[:stream_name]
    events = ReadWriteEventTestHelpers.write_events(streamName, 5)

    :ok = EventStore.subscribe_to_stream(self(), streamName, 0)
    assert_receive({:catchup_events, events})
  end
end
