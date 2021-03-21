defmodule EventStoreProjectionTest do
  use ExUnit.Case, async: false
  doctest EventStore.Projection

  setup context do
    [stream_name: StreamName.stream_name(context.test)]
  end

  test "produces an event type stream", context do
    stream1 = context[:stream_name]

    {:ok, _} =
      EventStore.write_event(%Event{
        stream_name: stream1,
        position: :any,
        data: %{first: true},
        event_type: "test"
      })

    {:ok, _} =
      EventStore.write_event(%Event{
        stream_name: stream1,
        position: :any,
        data: %{second: true},
        event_type: "test"
      })

    MailBox.wait_until_empty(GenServer.whereis(EventStore.Projection))

    events = EventStore.read_projection("et-test")

    assert [
             %Event{
               data: %{first: true},
               position: 0,
               stream_name: "et-test",
               event_type: "test",
               is_projected: true
             },
             %Event{
               data: %{second: true},
               position: 1,
               stream_name: "et-test",
               event_type: "test",
               is_projected: true
             }
           ] == events
  end
end
