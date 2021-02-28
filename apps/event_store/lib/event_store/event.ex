defmodule Event do
  @moduledoc """
  Structure of an event
  """
  @enforce_keys [:stream_name, :data]
  defstruct stream_name: nil, position: :not_set, data: nil
  @type t :: %Event{stream_name: String.t, position: atom | pos_integer, data: any}
end
