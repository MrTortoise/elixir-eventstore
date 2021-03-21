defmodule ProjectedStreamSupervisorTest do
  use ExUnit.Case, async: true
  doctest EventStore.ProjectedStream.Supervisor

  setup context do
    [streamName: StreamName.stream_name(context.test)]
  end

  test "getting a projection twice returns the same projected stream", context do
    stream1 = context[:stream_name]

    {:ok, pid1} = EventStore.ProjectedStream.Supervisor.get_projected_stream(stream1)
    {:ok, pid2} = EventStore.ProjectedStream.Supervisor.get_projected_stream(stream1)

    assert pid1 == pid2
  end

  test "getting a different projections returns different projected streams", context do
    stream1 = context[:stream_name]
    stream2 = "#{stream1}2"

    {:ok, pid1} = EventStore.ProjectedStream.Supervisor.get_projected_stream(stream1)
    {:ok, pid2} = EventStore.ProjectedStream.Supervisor.get_projected_stream(stream2)

    assert pid1 != pid2
  end
end
