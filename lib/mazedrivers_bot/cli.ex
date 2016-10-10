defmodule MazedriversBot.CLI do
  @moduledoc """
  CLI for usage via escript
  """
  alias MazedriversBot.Client
  alias MazedriversBot.Navigator

  @default_ws_host "localhost"
  @default_ws_port 8001

  def main(args) do
    args |> parse_args |> process
  end

  def process(options) do
    options
    |> validate_navigator
    |> set_default_host
    |> set_default_port
    |> set_default_nickname
    |> set_default_token
    |> Client.start
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [
        nickname: :string,
        token: :string,
        host: :string,
        port: :integer,
        navigator: :string,
      ]
    )
    options
  end

  def validate_navigator(options) do
    default_navigator = Navigator.random
    navigator =
      Keyword.get(options, :navigator) || Atom.to_string(default_navigator)
    unless Navigator.validate(navigator) do
      raise ArgumentError, message: "Invalid navigator #{navigator}"
    end
    Keyword.update(options, :navigator, default_navigator, &String.to_atom(&1))
  end

  defp set_default_host(options) do
    Keyword.update(options, :host, @default_ws_host, &(&1))
  end

  defp set_default_port(options) do
    Keyword.update(options, :port, @default_ws_port, &(&1))
  end

  defp set_default_nickname(options) do
    navigator = Keyword.get(options, :navigator)
    default_nickname = "#{navigator}#{:os.timestamp |> elem(2)}"
    Keyword.update(options, :nickname, default_nickname, &(&1))
  end

  defp set_default_token(options) do
    Keyword.update(options, :port, nil, &(&1))
  end
end
