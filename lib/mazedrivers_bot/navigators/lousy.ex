defmodule MazedriversBot.LousyNavigator do
  @moduledoc """
  Navigator that changes it's mind all the time
  """

  alias MazedriversBot.API

  def navigate(socket, state) do
    direction = Enum.random(["EAST", "WEST", "SOUTH", "NORTH"])
    API.drive_request(socket, direction)
  end
end
