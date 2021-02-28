defmodule EventStreamSupervisorTest do
  use ExUnit.Case, async: true

  test "calling get stream with same creates one child and returns it twice" do
    {:ok, stream1} = EventStore.EventStreams.Supervisor.get_stream("test1")
    {:ok, stream2} = EventStore.EventStreams.Supervisor.get_stream("test1")
    assert stream1 == stream2
  end

  test "calling get stream with different name creates 2 children" do
    {:ok, stream1} = EventStore.EventStreams.Supervisor.get_stream("test1")
    {:ok, stream2} = EventStore.EventStreams.Supervisor.get_stream("test2")
    assert stream1 != stream2
  end
end
