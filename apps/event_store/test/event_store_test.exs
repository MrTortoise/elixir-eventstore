defmodule EventStoreTest do
  use ExUnit.Case
  doctest EventStore

  test "when writing an event returns the written event" do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: "testStream"})
    assert written_event.stream_name == "testStream"
  end
end
