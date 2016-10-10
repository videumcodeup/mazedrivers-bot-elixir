# MazedriversBot

These are elixir bots for the [Mazedrivers][mazedrivers] game built for
[VideumCodeup][videumcodeup]. Start a server and connect with many of these bots
to see them in action driving against eachother.

## Dependencies
- You need to have elixir lang `brew install elixir`
- `mix deps.get` Fetch dependencies from hex.pm

## Build and run
- `mix escript.build && ./mazedrivers_bot`
- `mix escript.build && ./mazedrivers_bot --navigator=left`
- `mix escript.build && ./mazedrivers_bot --navigator=right`
- `mix escript.build && ./mazedrivers_bot --navigator=random`
- `mix escript.build && ./mazedrivers_bot --navigator=lousy`
- `mix escript.build && ./mazedrivers_bot --nickname=abc123`
- `mix escript.build && ./mazedrivers_bot --host=localhost`
- `mix escript.build && ./mazedrivers_bot --port 8001`

## Run linter
- `mix credo --strict`
- `mix credo --strict --oneline`

[mazedrivers]: https://github.com/videumcodeup?query=mazedrivers
[videumcodeup]: https://github.com/videumcodeup
