defmodule EventStore do
  @moduledoc """
  Documentation for `EventStore`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "dave"})
      {:ok, %Event{stream_name: "dave", position: 0}}
  """
  def write_event(event) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(event.stream_name)
    EventStore.EventStream.write_event(pid, event)
  end

  def read_stream(stream_name) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(stream_name)
    EventStore.EventStream.read(pid)
  end
end
