defmodule EventStream do
  use Agent

  def start_link(opts) do
    {event, opts} = Keyword.pop(opts, :first_event, %Event{})
    Agent.start_link(fn -> [event] end, opts)
  end
end
