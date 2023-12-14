defmodule Day10Test do
  use ExUnit.Case

  @tag :day10part1
  test "day 10, part 1" do
    board_map =
      File.read!("data_input/input10.txt")
      |> board_map()

    pipe_list = pipe_list(board_map)
    # |> IO.inspect(limit: :infinity)

    n = length(pipe_list)
    d = (n + 1) / 2

    assert d == 7093

    # {62, 64, :up, 14186},
    # {62, 65, :up, 14185},
    # {62, 66, :left, 14184},
    # {63, 66, :down, 14183},
  end

  defp pipe_list(board_map) do
    {start_x, start_y} = find_start(board_map)

    _first =
      {x, y, dir} =
      [
        {start_x, start_y - 1, :up},
        {start_x, start_y + 1, :down},
        {start_x + 1, start_y, :right},
        {start_x - 1, start_y, :left}
      ]
      |> Enum.find(fn {x, y, dir} ->
        tile = Map.fetch!(board_map, {x, y})
        next_tile({x, y, dir}, tile) != :nono
      end)

    pipe_list_recursive(board_map, {x, y, dir}, [], 1)
  end

  defp pipe_list_recursive(board_map, {x, y, dir}, pipe_list, n) do
    tile = Map.fetch!(board_map, {x, y})

    if tile == "S" do
      pipe_list
    else
      next = next_tile({x, y, dir}, tile)
      pipe_list_recursive(board_map, next, [{x, y, dir, n} | pipe_list], n + 1)
    end
  end

  defp next_tile({x, y, :up}, "|"), do: {x, y - 1, :up}
  defp next_tile({x, y, :down}, "|"), do: {x, y + 1, :down}
  defp next_tile({x, y, :right}, "-"), do: {x + 1, y, :right}
  defp next_tile({x, y, :left}, "-"), do: {x - 1, y, :left}

  defp next_tile({x, y, :down}, "L"), do: {x + 1, y, :right}
  defp next_tile({x, y, :left}, "L"), do: {x, y - 1, :up}
  defp next_tile({x, y, :down}, "J"), do: {x - 1, y, :left}
  defp next_tile({x, y, :right}, "J"), do: {x, y - 1, :up}
  defp next_tile({x, y, :up}, "7"), do: {x - 1, y, :left}
  defp next_tile({x, y, :right}, "7"), do: {x, y + 1, :down}
  defp next_tile({x, y, :up}, "F"), do: {x + 1, y, :right}
  defp next_tile({x, y, :left}, "F"), do: {x, y + 1, :down}

  defp next_tile(_, _), do: :nono

  defp find_start(board_map) do
    Enum.find(board_map, fn {{_x, _y}, tile} -> tile == "S" end)
    |> then(fn {{x, y}, "S"} -> {x, y} end)
  end

  defp board_map(full_str) do
    String.split(full_str, "\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line_str, y} ->
      String.split(line_str, "", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {single_str, x} -> {{x, y}, single_str} end)
    end)
    |> Map.new()
  end
end
