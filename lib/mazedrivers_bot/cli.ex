defmodule MazedriversBot.CLI do
  @moduledoc """
  CLI for usage via escript
  """

  def main(args) do
    args |> parse_args |> process
  end

  def process(options) do
    options
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
end
