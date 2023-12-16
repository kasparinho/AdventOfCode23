defmodule Day16Test do
  use ExUnit.Case

  @tag :day16
  test "day 16" do
    ## part 1
    board_map =
      File.read!("data_input/input16.txt")
      |> board_map()

    count =
      beam_closure(board_map, _start = {0, 0, :right})
      |> count_energized()

    assert count == 7046

    ## part 2
    max_count =
      start_beams(board_map)
      |> Stream.map(fn start ->
        beam_closure(board_map, start)
        |> count_energized()
      end)
      |> Enum.max()

    assert max_count == 7313
  end

  defp count_energized(beams_set) do
    MapSet.new(beams_set, fn {x, y, _dir} -> {x, y} end)
    |> MapSet.size()
  end

  defp beam_closure(board_map, start) do
    beam_closure_rec([start], MapSet.new(), board_map)
  end

  defp beam_closure_rec(
         [beam_open = {x, y, _dir} | tail],
         beams_closed_set,
         board_map
       ) do
    if Map.has_key?(board_map, {x, y}) and not MapSet.member?(beams_closed_set, beam_open) do
      beam_closure_rec(
        next(beam_open, Map.fetch!(board_map, {x, y})) ++ tail,
        MapSet.put(beams_closed_set, beam_open),
        board_map
      )
    else
      beam_closure_rec(tail, beams_closed_set, board_map)
    end
  end

  defp beam_closure_rec([], beams_closed_set, _board_map), do: beams_closed_set

  defp next({x, y, :left}, "."), do: [{x - 1, y, :left}]
  defp next({x, y, :right}, "."), do: [{x + 1, y, :right}]
  defp next({x, y, :up}, "."), do: [{x, y - 1, :up}]
  defp next({x, y, :down}, "."), do: [{x, y + 1, :down}]

  defp next({x, y, :left}, "|"), do: [{x, y - 1, :up}, {x, y + 1, :down}]
  defp next({x, y, :right}, "|"), do: [{x, y - 1, :up}, {x, y + 1, :down}]
  defp next({x, y, :up}, "|"), do: [{x, y - 1, :up}]
  defp next({x, y, :down}, "|"), do: [{x, y + 1, :down}]

  defp next({x, y, :left}, "-"), do: [{x - 1, y, :left}]
  defp next({x, y, :right}, "-"), do: [{x + 1, y, :right}]
  defp next({x, y, :up}, "-"), do: [{x - 1, y, :left}, {x + 1, y, :right}]
  defp next({x, y, :down}, "-"), do: [{x - 1, y, :left}, {x + 1, y, :right}]

  defp next({x, y, :left}, "/"), do: [{x, y + 1, :down}]
  defp next({x, y, :right}, "/"), do: [{x, y - 1, :up}]
  defp next({x, y, :up}, "/"), do: [{x + 1, y, :right}]
  defp next({x, y, :down}, "/"), do: [{x - 1, y, :left}]

  defp next({x, y, :left}, "\\"), do: [{x, y - 1, :up}]
  defp next({x, y, :right}, "\\"), do: [{x, y + 1, :down}]
  defp next({x, y, :up}, "\\"), do: [{x - 1, y, :left}]
  defp next({x, y, :down}, "\\"), do: [{x + 1, y, :right}]

  defp start_beams(board_map) do
    {max_x, max_y} = Map.keys(board_map) |> Enum.max()

    up_down = for x <- 0..max_x, do: [{x, 0, :down}, {x, max_y, :up}]
    left_right = for y <- 0..max_y, do: [{0, y, :right}, {max_x, y, :left}]

    Enum.concat(up_down ++ left_right)
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
