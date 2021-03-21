defmodule Event do
  @moduledoc """
  Structure of an event
  """
  @type t :: %Event{
    stream_name: String.t,
    position: :any | non_neg_integer,
    data: any,
    event_type: String.t,
    is_projected: boolean(),
    created_at: DateTime.t
  }
  @enforce_keys [:stream_name, :data, :position, :event_type]
  defstruct stream_name: nil, position: :any, data: nil, event_type: nil, is_projected: false, created_at: DateTime.utc_now()


end
