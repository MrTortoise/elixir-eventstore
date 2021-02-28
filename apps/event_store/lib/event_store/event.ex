defmodule Event do
   @moduledoc """
  Structure of an event
  """
  defstruct [:stream_name, :position, :data]

end
