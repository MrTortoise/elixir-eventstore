defmodule EventStoreAllStreamTest do
  use ExUnit.Case, async: true

  setup context do
    [streamName: StreamName.stream_name(context.test)]
  end


  @tag :skip
  test "when writing an event it gets added to the all stream", context do
    {:ok, written_event} = EventStore.write_event(%Event{stream_name: context[:streamName], data: %{}, position: :any, event_type: "test"})

    MailBox.wait_until_empty(GenServer.whereis(EventStore.Projection))

    events = EventStore.read_event_log()
    assert [written_event] == events
  end

end
