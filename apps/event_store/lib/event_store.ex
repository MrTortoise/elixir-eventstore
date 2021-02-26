defmodule EventStore do
  @moduledoc """
  Documentation for `EventStore`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> EventStore.write_event(%Event{stream_name: "dave"})
      {:ok, %Event{stream_name: "dave"}}

  """
  def write_event(event) do
    {:ok, event}
  end

end
