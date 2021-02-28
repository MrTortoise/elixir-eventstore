defmodule EventStoreSubscriptionTest do
  use ExUnit.Case, async: true

  setup context do
    [stream_name: StreamName.stream_name(context.test)]
  end

  test "when subscribe to stream expect to recieve all events", context do
    stream_name = context[:stream_name]
    _events = ReadWriteEventTestHelpers.write_events(stream_name, 5)

    :ok = EventStore.subscribe_to_stream(self(), stream_name, 0)

    assert_receive(
      {:catchup_events, _events},
      100,
      "did not recieve catchup events from the subscription"
    )

    _live_events = ReadWriteEventTestHelpers.write_events(stream_name, 5)

    assert_receive({:event, %Event{position: 5}})
    assert_receive({:event, %Event{position: 6}})
    assert_receive({:event, %Event{position: 7}})
    assert_receive({:event, %Event{position: 8}})
    assert_receive({:event, %Event{position: 9}})
  end
end
