defmodule MazedriversBot.RandomNavigator do
  @moduledoc """
  Navigator that navigates randomly
  """

  use MazedriversBot.BaseNavigator

  def navigate(socket, state) do
    direction = Enum.random(["EAST", "WEST", "SOUTH", "NORTH"])
    API.drive_request(socket, direction)
  end

  def get_preferred_directions(east, west, south, north) do
    %{
      "NORTH" => Enum.shuffle([west, north, east]) ++ [south],
      "EAST" => Enum.shuffle([north, east, south]) ++ [west],
      "SOUTH" => Enum.shuffle([east, south, west]) ++ [north],
      "WEST" => Enum.shuffle([south, west, north]) ++ [east],
    }
  end
end
