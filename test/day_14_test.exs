defmodule Day14Test do
  use ExUnit.Case

  @tag :day14part1
  test "day 14, part 1" do
    assert round_rock_weight_sum("data_input/input14_short.txt") == 136
    assert round_rock_weight_sum("data_input/input14.txt") == 109_424

    spin("data_input/input14_short.txt", 100)

    spin("data_input/input14.txt", 800)
  end

  defp spin(path, n_cycles) do
    strings =
      File.read!(path)
      |> String.split("\n")
      |> switch_over_corner()

    Enum.reduce(1..n_cycles, strings, fn c, strings ->
      full_cycle(strings)
      |> tap(fn x -> {c, weight(x)} |> IO.inspect() end)
    end)
  end

  defp full_cycle(strings) do
    strings
    # north
    |> gravitate()
    |> switch_over_corner()
    # west
    |> gravitate()
    |> switch_over_corner()
    |> mirror_world()
    # south
    |> gravitate()
    |> switch_over_corner()
    # east
    |> gravitate()
    |> switch_over_corner()
    |> mirror_world()
  end

  defp gravitate(strings),
    do: Enum.map(strings, &gravitate_line/1)

  defp gravitate_line(str) do
    str
    |> String.split(~r/(#)/, include_captures: true)
    |> Enum.map(fn str ->
      String.split(str, "", trim: true) |> Enum.sort(:desc)
    end)
    |> Enum.concat()
    |> Enum.join()
  end

  defp weight(strings),
    do: Enum.map(strings, &weight_line/1) |> Enum.sum()

  defp weight_line(str) do
    String.reverse(str)
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.filter(fn {s, _ix} -> s == "O" end)
    |> Enum.map(fn {_x, ix} -> ix + 1 end)
    |> Enum.sum()
  end

  defp switch_over_corner(strings),
    do:
      Enum.map(strings, &String.split(&1, "", trim: true))
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&Enum.join/1)

  defp mirror_world(strings),
    do:
      strings
      |> Enum.map(&String.reverse/1)
      |> Enum.reverse()

  ####

  defp round_rock_weight_sum(path) do
    board_map =
      File.read!(path)
      |> board_map()

    board_map
    |> to_cols()
    |> Enum.map(&round_rock_weight/1)
    |> Enum.sum()
  end

  defp round_rock_weight(col_list) do
    n = length(col_list)

    col_list
    |> Stream.transform(_last_occ = -1, fn
      {{_x, _y}, "."}, last_occ -> {[], last_occ}
      {{_x, _y}, "O"}, last_occ -> {[n - (last_occ + 1)], last_occ + 1}
      {{_x, y}, "#"}, _last_occ -> {[], y}
    end)
    |> Enum.to_list()
    |> Enum.sum()
  end

  defp to_cols(board_map) do
    board_map
    |> Enum.group_by(fn {{x, _y}, _single_str} -> x end)
    |> Map.values()
    |> Enum.map(&Enum.sort_by(&1, fn {{_x, y}, _single_str} -> y end))
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
