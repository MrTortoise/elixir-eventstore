defmodule ReadWriteEventTestHelpers do
  def write_events(_, 0), do: []

  def write_events(stream_name, number) do
    {:ok, written_event} =
      EventStore.write_event(%Event{stream_name: stream_name, data: %{"key" => "value#{number}"}})

    [written_event | write_events(stream_name, number - 1)]
  end
end
