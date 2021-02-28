defmodule EventStoreSubscriptionTest do
  use ExUnit.Case, async: true
  doctest EventStore

  test "when writing an event returns the written event" do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event.position == 0
  end

  @tag :skip
  test "when subscribe to stream expect to recieve all events" do
    # realised that event types will put more design pressure on system for now
  end




end
