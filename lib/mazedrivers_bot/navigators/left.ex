defmodule MazedriversBot.LeftNavigator do
  @moduledoc """
  Navigator that turn left in every crossing
  """

  use MazedriversBot.BaseNavigator

  def get_preferred_directions(east, west, south, north) do
    %{
      "NORTH" => [west, north, east, south],
      "EAST" => [north, east, south, west],
      "SOUTH" => [east, south, west, north],
      "WEST" => [south, west, north, east],
    }
  end
end
