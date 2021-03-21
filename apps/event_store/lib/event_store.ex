defmodule EventStore do
  @moduledoc """
  Documentation for `EventStore`.
  """

  @spec write_event(Event.t()) :: {:ok, Event.t()}
  @doc """
  Writes an event.

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "estest1", data: %{}, position: :any, event_type: "test"})
      {:ok, %Event{stream_name: "estest1", position: 0, data: %{}, event_type: "test"}}
  """
  def write_event(event) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(event.stream_name)
    EventStore.EventStream.write_event(pid, event)
  end

  @doc """
  Reads an entire event stream.

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "estest2", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.write_event(%Event{stream_name: "estest2", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.read_stream("estest2")
      [
        %Event{stream_name: "estest2", position: 0, data: %{}, event_type: "test"},
        %Event{stream_name: "estest2", position: 1, data: %{}, event_type: "test"}
      ]
  """
  @spec read_stream(String.t()) :: [Event.t()]
  def read_stream(stream_name) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(stream_name)
    EventStore.EventStream.read_stream(pid)
  end

  @doc """
  Plucks an event by position from a stream

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "estest3", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.write_event(%Event{stream_name: "estest3", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.read_event("estest3",1)
      {:ok, %Event{stream_name: "estest3", position: 1, data: %{}, event_type: "test"}}
  """
  @spec read_event(String.t(), non_neg_integer) :: {:not_found} | {:ok, Event.t()}
  def read_event(stream_name, position) when is_integer(position) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(stream_name)
    EventStore.EventStream.read_position(pid, position)
  end

  @doc """
  subscribes to a stream, will return :ok and send messages to the subscriber
  The first message will be a `{:catchup_events, [Event.t]}`, followed by individual messages `{:event, Event.t}` for each future event

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "estest4", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.subscribe_to_stream(self(), "estest4", 0)
      :ok
  """
  @spec subscribe_to_stream(atom | pid | port | {atom, atom}, String.t(), non_neg_integer) :: :ok
  def subscribe_to_stream(subscriber, stream_name, position) when is_integer(position) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(stream_name)
    EventStore.EventStream.subscribe_from_position(pid, subscriber, position)
  end

  def create_projection(name, predicate, stream_name) do
    EventStore.Projection.create(%EventStore.Projection{name: name, predicate: predicate, stream_name: stream_name})
  end

  def read_projection(name) do
    {:ok, projection} = EventStore.ProjectedStream.Supervisor.get_projected_stream(name)

    EventStore.ProjectedStream.read(projection)
    |> EventStore.ProjectedStream.map_to_events()
    |> Enum.reverse

  end
end
