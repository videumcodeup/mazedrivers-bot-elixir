defmodule MazedriversBot.Navigator do
  @moduledoc """
  Navigator continously figures out where to drive next
  """

  @interval 150

  require Logger
  alias MazedriversBot.GameState
  alias MazedriversBot.LeftNavigator
  alias MazedriversBot.LousyNavigator
  alias MazedriversBot.RandomNavigator
  alias MazedriversBot.RightNavigator

  @navigators %{
    random: RandomNavigator,
    left: LeftNavigator,
    right: RightNavigator,
    lousy: LousyNavigator,
  }

  def random do
    @navigators |> Map.keys |> Enum.random
  end

  def validate(navigator) do
    @navigators
    |> Map.keys
    |> Enum.map(&Atom.to_string/1)
    |> Enum.member?(navigator)
  end

  def start(socket, state_pid) do
    spawn(fn -> loop(socket, state_pid) end)
  end

  def loop(socket, state_pid) do
    :erlang.send_after(@interval, self(), {:continue})
    receive do
      {:continue} ->
        state = GameState.get(state_pid)
        cond do
          state.nickname == nil ->
            loop(socket, state_pid)
          state.maze == nil ->
            loop(socket, state_pid)
          state.details["predicates"]["isStarted"] == false ->
            loop(socket, state_pid)
          state.players[state.nickname]["finished"] == true ->
            nil
          true ->
            @navigators[state.navigator].navigate(socket, state)
            loop(socket, state_pid)
        end
    end
  end
end
