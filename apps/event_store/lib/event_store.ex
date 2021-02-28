defmodule EventStore do
  @moduledoc """
  Documentation for `EventStore`.
  """

  @spec write_event(Event.t) :: {:ok, Event.t}
  @doc """
  Hello world.

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "dave", data: %{}, position: :any})
      {:ok, %Event{stream_name: "dave", position: 0, data: %{}}}
  """
  def write_event(event) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(event.stream_name)
    EventStore.EventStream.write_event(pid, event)
  end

  @spec read_stream(String.t) :: [Event.t]
  def read_stream(stream_name) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(stream_name)
    EventStore.EventStream.read_stream(pid)
  end

  @spec read_event(String.t, non_neg_integer) :: {:not_found} | {:ok, Event.t}
  def read_event(stream_name, position) when is_integer(position)  do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(stream_name)
    EventStore.EventStream.read_position(pid, position)
  end

  @spec subscribe_to_stream(atom | pid | port | {atom, atom}, String.t, non_neg_integer) :: :ok
  def subscribe_to_stream(subscriber, stream_name, position) when is_integer(position) do
    {:ok, pid} = EventStore.EventStreams.Supervisor.get_stream(stream_name)
    EventStore.EventStream.subscribe_from_position(pid, subscriber, position)
  end

end
