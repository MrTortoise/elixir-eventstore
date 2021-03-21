defmodule EventStoreLogTest do
  use ExUnit.Case, async: true

  setup context do
    [stream_name: StreamName.stream_name(context.test)]
  end

  test "returns written events in the correct order", context do
    stream1 = context[:stream_name]
    stream2 = "#{stream1}2"

    {:ok, _} =
      EventStore.write_event(%Event{
        stream_name: stream1,
        position: :any,
        data: %{first: true},
        event_type: "test"
      })

    {:ok, _} =
      EventStore.write_event(%Event{
        stream_name: stream2,
        position: :any,
        data: %{second: true},
        event_type: "test2"
      })

    MailBox.wait_until_empty(GenServer.whereis(EventStore.EventLog))

    events =
      EventStore.EventLog.read()
      |> Enum.filter(fn e ->
        e.source_stream_name == stream1 || e.source_stream_name == stream2
      end)
      |> Enum.reverse() # new events appended to head

    assert Enum.count(events) == 2

    first = Enum.at(events, 0)
    assert first.source_stream_name == stream1

    last = Enum.at(events, 1)
    assert last.source_stream_name == stream2
  end
end
