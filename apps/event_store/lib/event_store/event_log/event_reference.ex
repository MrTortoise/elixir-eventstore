defmodule EventStore.EventReference do
  @enforce_keys [:position, :stream_position, :source_stream_name, :stream_name]
  defstruct [:position, :stream_position, :source_stream_name, :stream_name]

  @type t() :: %__MODULE__{
          position: non_neg_integer(),
          stream_position: non_neg_integer(),
          source_stream_name: String.t(),
          stream_name: String.t()
        }
end
