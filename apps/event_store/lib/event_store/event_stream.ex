defmodule EventStore.EventStream do
  use Agent, restart: :temporary

  @moduledoc """
  Represents an event stream as a process
  Used to read, write and subscribe at a stream level

  Not backed by persistence atm
  """

  def start_link(opts) do
    Agent.start_link(fn -> %{events: [], subscriptions: []} end, opts)
  end

  # events are written in reverse order
  # its 'more efficient' to write to a list like this ... i bet it sucks later though ...
  @spec write_event(atom | pid | {atom, any} | {:via, atom, any}, Event.t) :: {:ok, Event.t}
  def write_event(pid, event) do
    state = Agent.get(pid, & &1)
    event_to_write = write_new_event(pid, state, event)
    publish_to_subscriptions(state, event_to_write)

    {:ok, event_to_write}
  end

  @spec read_stream(atom | pid | {atom, any} | {:via, atom, any}) :: [Event.t]
  def read_stream(pid) do
    Agent.get(pid, & &1).events
    |> Enum.reverse()
  end

  def read_position(pid, position) when is_integer(position) and position >=0 do
    read_stream(pid)
    |> first(&(&1.position == position))
  end

  def read_forward_from_position(pid, position) when is_integer(position) and position >=0 do
    read_stream(pid)
    |> get_events_from_position(position)
  end

  def subscribe_from_position(pid, subscriber, position) when is_integer(position) and position >=0 do
    %{events: events, subscriptions: subscriptions} = Agent.get(pid, & &1)

    catchup_events =
      events
      |> Enum.reverse()
      |> get_events_from_position(position)

    Process.send(subscriber, {:catchup_events, catchup_events}, [])

    Agent.update(pid, fn state -> %{state | subscriptions: [subscriber | subscriptions]} end)
  end

  defp write_new_event(pid, %{events: events}, event) do
    event_to_write = %{event | position: Enum.count(events)}
    Agent.update(pid, fn state -> %{state | events: [event_to_write | state.events]} end)
    event_to_write
  end

  defp publish_to_subscriptions(%{subscriptions: subscriptions}, event) do
    subscriptions
    |> Enum.each(fn s -> Process.send(s, {:event, event}, []) end)
  end

  defp first([], _), do: {:not_found}

  defp first([h | tail], pred) do
    if pred.(h) do
      {:ok, h}
    else
      first(tail, pred)
    end
  end

  @spec get_events_from_position([Event.t], non_neg_integer) :: [Event.t]
  defp get_events_from_position([], _), do: []

  defp get_events_from_position([e | tail], position) do
    if e.position == position do
      [e | tail]
    else
      get_events_from_position(tail, position)
    end
  end
end
