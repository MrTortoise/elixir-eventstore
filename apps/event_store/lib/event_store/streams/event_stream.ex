defmodule EventStore.EventStream do
  use Agent, restart: :temporary

  @moduledoc """
  Represents an event stream as a process
  Used to read, write and subscribe at a stream level

  Not backed by persistence atm

  Added typespecs where it gets it a bit too general (structs and maps for instance) to make easier on eyes when consuming

  Writes the event into its stream, writes it to the event log, publishes it to its subscriptions and then passes it to projections
  """

  def start_link(opts) do
    Agent.start_link(fn -> %{events: [], subscriptions: [], position: -1} end, opts)
  end

  @spec write_event(atom | pid | {atom, any} | {:via, atom, any}, Event.t()) :: {:ok, Event.t()}
  def write_event(stream_pid, event) do
    %{position: position, subscriptions: subscriptions} = Agent.get(stream_pid, & &1)
    event_to_write = %{event | position: position + 1}

    event_to_write
    |> write_new_event(stream_pid)
    |> EventStore.EventLog.write()
    |> publish_to_subscriptions(subscriptions)
    |> EventStore.Projection.project_event()

    {:ok, event_to_write}
  end

  @spec read_stream(atom | pid | {atom, any} | {:via, atom, any}) :: [Event.t()]
  def read_stream(pid) do
    Agent.get(pid, & &1).events
    |> Enum.reverse()
  end

  def read_position(pid, position)
      when is_integer(position) and position >= 0 do
    read_stream(pid)
    |> first(&(&1.position == position)) # i dont really want events to be deletable ... but you know ...
  end

  def read_forward_from_position(pid, position)
      when is_integer(position) and position >= 0 do
    read_stream(pid)
    |> get_events_from_position(position)
  end

  def subscribe_from_position(pid, subscriber, position)
      when is_integer(position) and position >= 0 do
    %{events: events, subscriptions: subscriptions} = Agent.get(pid, & &1)

    catchup_events =
      events
      |> Enum.reverse()
      |> get_events_from_position(position)

    Process.send(subscriber, {:catchup_events, catchup_events}, [])

    Agent.update(pid, fn state -> %{state | subscriptions: [subscriber | subscriptions]} end)
  end

  defp write_new_event(event, stream_pid) do
    Agent.update(stream_pid, fn state ->
      %{
        state
        | events: [event | state.events],
          position: event.position
      }
    end)

    event
  end

  defp publish_to_subscriptions(event, subscriptions) do
    subscriptions
    |> Enum.each(fn s -> Process.send(s, {:event, event}, []) end)

    event
  end

  defp first([], _), do: {:not_found}

  defp first([h | tail], pred) do
    if pred.(h) do
      {:ok, h}
    else
      first(tail, pred)
    end
  end

  @spec get_events_from_position([Event.t()], non_neg_integer) :: [Event.t()]
  defp get_events_from_position([], _), do: []

  defp get_events_from_position([e | tail], position) do
    if e.position == position do
      [e | tail]
    else
      get_events_from_position(tail, position)
    end
  end
end
