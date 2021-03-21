defmodule EventStore.ProjectedStream.Supervisor do
  use DynamicSupervisor

    @moduledoc """
  Manages creating projection streams
  """

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
