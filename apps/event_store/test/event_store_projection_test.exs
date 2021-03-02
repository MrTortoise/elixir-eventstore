defmodule EventStoreProjectionTest do
  use ExUnit.Case, async: true
  doctest EventStore.Projection

  setup context do
    [stream_name: StreamName.stream_name(context.test)]
  end

  test "a projection that returns true should capture all events", context do
    stream1 = context[:stream_name]
    stream2 = "#{stream1}2"
    s = self()

    {:ok} =
      EventStore.create_projection("all", fn _ -> true end, fn _ ->
        Process.send(s, :done, [])
        "all"
      end)

    {:ok, _} = EventStore.write_event(%Event{stream_name: stream1, position: :any, data: %{}})
    {:ok, _} = EventStore.write_event(%Event{stream_name: stream2, position: :any, data: %{}})
    assert_receive :done
    assert_receive :done
    events = EventStore.read_stream("all")

    assert [
             %Event{data: %{}, position: 0, stream_name: "all"},
             %Event{data: %{}, position: 1, stream_name: "all"}
           ] == events
  end
end
