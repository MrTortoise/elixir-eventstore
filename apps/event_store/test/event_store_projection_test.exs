defmodule EventStoreProjectionTest do
  use ExUnit.Case, async: true
  doctest EventStore.Projection

  setup context do
    [stream_name: StreamName.stream_name(context.test)]
  end


  test "a projection that returns true should capture all events", context do
    stream1 = context[:stream_name]
    _stream2 = "#{stream1}2"

    {:ok} = EventStore.create_projection("all", fn _ -> true end, fn _ -> "all" end)
    {:ok, _} = EventStore.write_event(%Event{stream_name: "dave", position: :any, data: %{}})
    events = EventStore.read_stream("all")
    assert 1 = Enum.count(events)
  end
end
