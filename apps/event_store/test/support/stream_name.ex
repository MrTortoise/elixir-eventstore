defmodule StreamName do
  def stream_name(testName) do
    String.split(Atom.to_string(testName))
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join()
  end
end
