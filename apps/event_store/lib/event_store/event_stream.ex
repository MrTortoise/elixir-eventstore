defmodule EventStore.EventStream do
  use Agent, restart: :temporary

  @moduledoc """
  Represents an event stream as a process
  Used to read, write and subscribe at a stream level

  Not backed by persistence atm
  """

  def start_link(opts) do
    Agent.start_link(fn -> [] end, opts)
  end

  # events are written in reverse order
  # its 'more efficient' to write to a list like this ... i bet it sucks later though ...
  def write_event(pid, event) do
    events = Agent.get(pid, & &1)
    event_to_write = %{event | position: Enum.count(events)}
    events_to_write = [event_to_write | events]
    Agent.update(pid, fn _ -> events_to_write end)
    {:ok, event_to_write}
  end

  def read_stream(pid) do
    Agent.get(pid, & &1)
    |> Enum.reverse()
  end

  def read_position(pid, position) do
    Agent.get(pid, & &1)
    |> first(&(&1.position == position))
  end

  def read_forward_from_position(pid, position) do
    read_stream(pid)
    |> get_events_from_position(position)
  end

  def subscribe_from_position(pid, subscriber, position) do
    catchup_events = read_forward_from_position(pid, position)
    Process.send(subscriber, {:catchup_events, catchup_events}, [])
    :ok
  end

  defp first([], _), do: {:not_found}

  defp first([h | tail], pred) do
    if pred.(h) do
      {:ok, h}
    else
      first(tail, pred)
    end
  end

  defp get_events_from_position([], _), do: []

  defp get_events_from_position([e | tail], position) do
    if e.position == position do
      [e | tail]
    else
      get_events_from_position(tail, position)
    end
  end
end
