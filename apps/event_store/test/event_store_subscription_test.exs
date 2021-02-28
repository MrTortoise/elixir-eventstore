defmodule EventStoreSubscriptionTest do
  use ExUnit.Case, async: true
  doctest EventStore

  test "when writing an event returns the written event" do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event.position == 0
  end

  test "when subscribe to stream expect to recieve all events" do

  end




end
