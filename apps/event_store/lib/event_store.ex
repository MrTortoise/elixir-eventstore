defmodule EventStore do
  @moduledoc """
  Documentation for `EventStore`.
  """

  @spec write_event(any) :: {:ok, %{:position => 0, optional(any) => any}, pid}
  @doc """
  Hello world.

  ## Examples

      iex>{:ok, %Event{stream_name: "dave"}, pid} = EventStore.write_event(%Event{stream_name: "dave"})
      iex>is_pid(pid)
      true
  """
  def write_event(event) do

     {:ok, pid} = EventStore.EventStreamSupervisor.get_stream(event.stream_name)
     EventStream.start_link([{:first_event, event}])
  end


end
