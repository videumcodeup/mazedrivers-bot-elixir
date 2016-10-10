defmodule MazedriversBot.BaseNavigator do
  @moduledoc """
  Base navigator used by LeftNavigator, RightNavigator, RandomNavigator
  """

  @callback get_preferred_directions(list, list, list, list) :: map
  @callback navigate(map, map) :: any
  @callback get_direction(map) :: String.t
  @callback assign_cell(map, map) :: map
  @callback get_neighbours(map) :: list

  defmacro __using__(_) do
    quote do
      alias MazedriversBot.API
      require Logger

      @behaviour unquote(__MODULE__)

      def navigate(socket, state) do
        speed = state.players[state.nickname]["speed"]
        current_direction = state.players[state.nickname]["direction"]
        new_direction = get_direction(state)
        cond do
          new_direction == nil ->
            Logger.warn "Could not get direction"
          new_direction == current_direction && speed == 1 ->
            nil
          true ->
            API.drive_request(socket, new_direction)
        end
      end

      defp get_direction(%{nickname: nickname, maze: maze, players: players}) do
        players
        |> Map.get(nickname)
        |> get_neighbours
        |> Enum.map(&assign_cell(&1, maze))
        |> Enum.reject(fn %{cell: cell} -> cell == "wall" end)
        |> Enum.reject(fn %{cell: cell} -> cell == "corner" end)
        |> Enum.reject(fn %{cell: cell} -> cell == nil end)
        |> Enum.map(&(&1.direction))
        |> List.first
      end

      def assign_cell(%{x: x, y: y} = map, maze) do
        Map.put(map, :cell, maze[y][x])
      end

      def get_neighbours(%{"x" => x, "y" => y, "direction" => direction}) do
        east = %{x: x + 1, y: y, direction: "EAST"}
        west = %{x: x - 1, y: y, direction: "WEST"}
        south = %{x: x, y: y + 1, direction: "SOUTH"}
        north = %{x: x, y: y - 1, direction: "NORTH"}
        preferred_directions =
          get_preferred_directions(east, west, south, north)
        neighbours = preferred_directions[direction]
        unless neighbours do
          Logger.error("Unexpected neighbours #{neighbours}")
        end
        neighbours
      end

      def get_neighbours(player) do
        Logger.error("Unexpected player #{inspect player}")
        []
      end
    end
  end

end
