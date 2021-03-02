defmodule EventStore do
  @moduledoc """
  Documentation for `EventStore`.
  """

  @spec write_event(Event.t()) :: {:ok, Event.t()}
  @doc """
  Writes an event.

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "dave", data: %{}, position: :any, event_type: "test"})
      {:ok, %Event{stream_name: "dave", position: 0, data: %{}, event_type: "test"}}
  """
  def write_event(event) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(event.stream_name)
    EventStore.EventStream.write_event(pid, event)
  end

  @doc """
  Reads an entire event stream.

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "dave", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.write_event(%Event{stream_name: "dave", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.read_stream("dave")
      [
        %Event{stream_name: "dave", position: 0, data: %{}, event_type: "test"},
        %Event{stream_name: "dave", position: 1, data: %{}, event_type: "test"}
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

      iex> EventStore.write_event(%Event{stream_name: "dave", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.write_event(%Event{stream_name: "dave", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.read_event("dave",1)
      {:ok, %Event{stream_name: "dave", position: 1, data: %{}, event_type: "test"}}
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

      iex> EventStore.write_event(%Event{stream_name: "dave", data: %{}, position: :any, event_type: "test"})
      iex> EventStore.subscribe_to_stream(self(), "dave", 0)
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
end
