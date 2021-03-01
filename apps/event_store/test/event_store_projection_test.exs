defmodule EventStoreProjectionTest do
  use ExUnit.Case, async: true
  doctest EventStore.Projection

  setup context do
    [stream_name: StreamName.stream_name(context.test)]
  end

  @tag :skip
  test "a projection that returns true should capture all events", context do
    stream1 = context[:stream_name]
    _stream2 = "#{stream1}2"

    EventStore.create_projection("all", fn _ -> true end)
  end
end
