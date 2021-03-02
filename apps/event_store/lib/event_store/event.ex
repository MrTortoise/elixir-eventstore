defmodule Event do
  @moduledoc """
  Structure of an event
  """
  @type t :: %Event{
    stream_name: String.t(),
    position: :any | non_neg_integer,
    data: any
  }
  @enforce_keys [:stream_name, :data, :position]
  defstruct stream_name: nil, position: :any, data: nil


end
