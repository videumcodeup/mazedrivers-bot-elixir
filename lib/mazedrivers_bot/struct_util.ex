defmodule MazedriversBot.StructUtil do
  @moduledoc """
  Helpers for working with structs
  """

  require Logger

  def map_put_in(map, [key], val), do:
    Map.put(map, key, val)
  def map_put_in(map, [key | tail], val) do
    child_map = Map.get(map, key) || %{}
    Map.put(map, key, map_put_in(child_map, tail, val))
  end
end
