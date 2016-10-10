defmodule MazedriversBot.GameState do
  @moduledoc """
  Agent that handles game state
  """

  require Logger

  defstruct [:navigator, :nickname, :token, :details, :players, :maze]

  def start! do
    {:ok, pid} = Agent.start(fn -> %__MODULE__{} end)
    pid
  end

  def get(pid) do
    Agent.get(pid, &(&1))
  end

  def update_navigator(pid, navigator) do
    Agent.update(pid, &%{&1 | navigator: navigator})
  end

  def update_join_success(pid, %{"nickname" => nickname, "token" => token}) do
    Logger.debug("#{nickname} #{token}")
    Agent.update(pid, &%{&1 | nickname: nickname, token: token})
  end

  def update_full_state(pid, %{"details" => d, "players" => p, "maze" => m}) do
    maze = maze_into_map(m)
    Agent.update(pid, &%{&1 | details: d, players: p, maze: maze})
  end

  def update_state(pid, updates) do
    Agent.update pid, fn state ->
      Enum.reduce(updates, state, &apply_update/2)
    end
  end

  defp apply_update([coll, scope, key, val], state) do
    case sanitize(coll, scope, key) do
      [coll, scope, key] ->
        map_put_in(state, [coll, scope, key], val)
      _ ->
        Logger.warn("Unknown update #{inspect [coll, scope, key, val]}")
        state
    end
  end

  defp apply_update(["maze", maze], state) do
    %{state | maze: maze_into_map(maze)}
  end

  defp apply_update(update, state) do
    Logger.warn("Unknown update #{inspect update}")
    state
  end


  @spec sanitize(String.t, any, any) :: list | nil
  defp sanitize("players", nick, "direction"), do: [:players, nick, "direction"]
  defp sanitize("players", nick, "finished"), do: [:players, nick, "finished"]
  defp sanitize("players", nick, "nickname"), do: [:players, nick, "nickname"]
  defp sanitize("players", nick, "speed"), do: [:players, nick, "speed"]
  defp sanitize("players", nick, "style"), do: [:players, nick, "style"]
  defp sanitize("players", nick, "timeEnd"), do: [:players, nick, "timeEnd"]
  defp sanitize("players", nick, "timeStart"), do: [:players, nick, "timeStart"]
  defp sanitize("players", nick, "x"), do: [:players, nick, "x"]
  defp sanitize("players", nick, "y"), do: [:players, nick, "y"]
  defp sanitize("maze", y, x), do: [:maze, y, x]
  defp sanitize("details", "entrance", "x"), do: [:details, "entrance", "x"]
  defp sanitize("details", "entrance", "y"), do: [:details, "entrance", "y"]
  defp sanitize("details", "exit", "x"), do: [:details, "exit", "x"]
  defp sanitize("details", "exit", "y"), do: [:details, "exit", "y"]
  defp sanitize("details", "predicates", "isStarted"),
    do: [:details, "predicates", "isStarted"]
  defp sanitize("details", "predicates", "isStarting"),
    do: [:details, "predicates", "isStarting"]
  defp sanitize(coll, scope, key) do
    Logger.warn("Sanitize found no match for #{{coll, scope, key}}")
    nil
  end

  defp maze_into_map(maze) do
    maze
    |> Enum.map(&list_into_map/1)
    |> list_into_map
  end

  defp list_into_map(list) do
    list
    |> Enum.with_index
    |> Enum.map(fn {value, index} -> {index, value} end)
    |> Enum.into(%{})
  end

  def map_put_in(map, [key], val), do:
    Map.put(map, key, val)
  def map_put_in(map, [key | tail], val) do
    child_map = Map.get(map, key) || %{}
    Map.put(map, key, map_put_in(child_map, tail, val))
  end
end
