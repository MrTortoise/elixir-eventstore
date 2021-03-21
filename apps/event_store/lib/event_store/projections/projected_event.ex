defmodule EventStore.ProjectedEvent do

  @type t :: %EventStore.ProjectedEvent{
    projection_name: String.t,
    position: :any | non_neg_integer,
    stream_name: String.t,
    stream_position: :any | non_neg_integer
  }
@enforce_keys [:projection_name, :position, :stream_name, :stream_position]
defstruct [:projection_name, :position, :stream_name, :stream_position]

end
