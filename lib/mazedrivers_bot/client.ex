defmodule MazedriversBot.Client do
  @moduledoc """
  MazedriversBot main file
  """
  alias MazedriversBot.GameState
  alias MazedriversBot.Navigator
  alias MazedriversBot.API
  alias Poison.Parser
  alias Socket.Web
  require Logger

  def start(options) do
    host = Keyword.get(options, :host)
    port = Keyword.get(options, :port)
    nickname = Keyword.get(options, :nickname)
    token = Keyword.get(options, :token)
    navigator = Keyword.get(options, :navigator)
    socket = Web.connect!(host, port)
    state_pid = GameState.start!
    GameState.update_navigator(state_pid, navigator)
    navigator_pid = Navigator.start(socket, state_pid)
    API.join_request(socket, nickname)
    loop(socket, state_pid)
  end

  def wait(socket, state_pid) do
    receive do
      {:continue} -> loop(socket, state_pid)
    end
  end

  def loop(socket, state_pid) do
    case Web.recv!(socket) do
      {:ping, _} ->
        Web.send!(socket, {:pong, ""})
        loop(socket, state_pid)

      {:text, text} ->
        handle_text(socket, state_pid, text)

      {:close, :abnormal, _} ->
        Logger.warn "Lost connection"
        wait(socket, state_pid)

      data ->
        Logger.warn("Unexpected #{inspect data} received")
        loop(socket, state_pid)
    end
  end

  def handle_text(socket, state_pid, data) do
    case Parser.parse(data) do
      {:ok, list} when is_list(list) ->
        handle_updates(socket, state_pid, list)

      {:ok, action} when is_map(action) ->
        log_failure(action)
        handle_action(socket, state_pid, action["type"], action["payload"])

      {:ok, data} ->
        Logger.warn("Unexpected json #{inspect data} received")
        loop(socket, state_pid)
    end
  end

  def handle_updates(socket, state_pid, updates) when is_list(updates) do
    GameState.update_state(state_pid, updates)
    loop(socket, state_pid)
  end

  def handle_action(socket, state_pid, "JOIN_SUCCESS", payload) do
    GameState.update_join_success(state_pid, payload)
    loop(socket, state_pid)
  end

  def handle_action(socket, state_pid, "JOIN_FAILURE", payload) do
    Logger.warn("JOIN_FAILURE #{inspect payload}")
    loop(socket, state_pid)
  end

  def handle_action(socket, state_pid, "REJOIN_SUCCESS", payload) do
    GameState.update_join_success(state_pid, payload)
    loop(socket, state_pid)
  end

  def handle_action(socket, state_pid, "STATE", payload) do
    GameState.update_full_state(state_pid, payload)
    loop(socket, state_pid)
  end

  def handle_action(socket, state_pid, "DRIVE_SUCCESS", _payload) do
    loop(socket, state_pid)
  end

  def handle_action(socket, state_pid, type, payload) do
    Logger.warn("Unhandled action #{type} received")
    loop(socket, state_pid)
  end

  def log_failure(action) do
    if Regex.match?(~r(.+_FAILURE), action["type"]) do
      Logger.warn("#{action["type"]} #{inspect action["payload"]}")
    end
  end
end
