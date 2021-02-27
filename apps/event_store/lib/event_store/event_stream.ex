defmodule EventStore.EventStream do
  use Agent, restart: :temporary

  def start_link(opts) do
    Agent.start_link(fn -> [] end, opts)
  end

  def write_event(pid, event) do
    events = Agent.get(pid, & &1)
    event_to_write = %{event | position: Enum.count(events)}
    events_to_write = [event_to_write | events]
    Agent.update(pid, fn _ -> events_to_write end)
    {:ok, event_to_write}
  end

  def read(pid) do
    Agent.get(pid, & &1)
    |> Enum.reverse()
  end
end
