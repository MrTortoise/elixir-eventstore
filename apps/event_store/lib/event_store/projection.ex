defmodule EventStore.Projection do
  use Agent, restart: :temporary


  def start_link(opts) do
    Agent.start_link(fn -> [] end, opts)
  end

  def create(name, predicate) do

  end
end
