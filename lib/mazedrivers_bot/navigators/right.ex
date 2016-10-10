defmodule MazedriversBot.RightNavigator do
  @moduledoc """
  Navigator that turn right in every crossing
  """

  use MazedriversBot.BaseNavigator

  def get_preferred_directions(east, west, south, north) do
    %{
      "NORTH" => [east, north, west, south],
      "EAST" => [south, east, north, west],
      "SOUTH" => [west, south, east, north],
      "WEST" => [north, west, south, east],
    }
  end
end
