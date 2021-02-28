defmodule Event do
  @moduledoc """
  Structure of an event
  """
  @enforce_keys [:stream_name, :data, :position]
  defstruct stream_name: nil, position: :any, data: nil
  @type t :: %Event{
    stream_name: String.t,
    position: :any | non_neg_integer,
    data: any
  }
end
