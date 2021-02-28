defmodule EventStreamSupervisorTest do
  use ExUnit.Case, async: true

  setup context do
    [streamName: StreamName.stream_name(context.test)]
  end

  test "calling get stream with same creates one child and returns it twice", context do
    {:ok, stream1} = EventStore.EventStreams.Supervisor.get_stream("#{context[:streamName]}test1")
    {:ok, stream2} = EventStore.EventStreams.Supervisor.get_stream("#{context[:streamName]}test1")
    assert stream1 == stream2
  end

  test "calling get stream with different name creates 2 children", context do
    {:ok, stream1} = EventStore.EventStreams.Supervisor.get_stream("#{context[:streamName]}test1")
    {:ok, stream2} = EventStore.EventStreams.Supervisor.get_stream("#{context[:streamName]}test2")
    assert stream1 != stream2
  end
end
