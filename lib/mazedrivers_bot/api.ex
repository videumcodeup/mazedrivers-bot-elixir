defmodule MazedriversBot.API do
  @moduledoc """
  API layer for communication with mazedrivers websocket server API
  """
  alias Socket.Web
  require Logger

  def join_request(socket, nickname) do
    Logger.debug "join_request #{inspect nickname}"
    action = %{type: "JOIN_REQUEST", payload: %{nickname: "#{nickname}"}}
    socket |> send!(action)
  end

  def drive_request(socket, "WEST" = dir), do: do_drive(socket, dir)
  def drive_request(socket, "EAST" = dir), do: do_drive(socket, dir)
  def drive_request(socket, "NORTH" = dir), do: do_drive(socket, dir)
  def drive_request(socket, "SOUTH" = dir), do: do_drive(socket, dir)

  defp do_drive(socket, direction) do
    action = %{type: "DRIVE_REQUEST", payload: direction}
    socket |> send!(action)
  end

  def send!(socket, action) when is_map(action) do
    socket |> Web.send!({:text, Poison.encode!(action)})
    Logger.debug("send! #{inspect Poison.encode!(action)}")
  end
end
