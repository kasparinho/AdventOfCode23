defmodule Day3Test do
  use ExUnit.Case

  @tag :day3part1
  test "day 3, part 1" do
    things =
      File.read!("data_input/input3.txt")
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {line_str, lix} ->
        decompose(line_str, lix)
      end)

    # map: line_nr => set of symbol positions
    line_symbol_pos_map =
      Enum.filter(things, &symbol_tuple?/1)
      |> Enum.group_by(fn {:symbol, _str, _pos, line} -> line end, fn {:symbol, _str, pos, _line} ->
        pos
      end)
      |> Map.new(fn {line, list} -> {line, MapSet.new(list)} end)

    sum =
      things
      |> Enum.reject(&symbol_tuple?/1)
      |> Enum.filter(&has_symbol_adjacent?(&1, line_symbol_pos_map))
      |> Enum.map(fn {:number, n, _, _} -> n end)
      |> Enum.sum()

    assert sum == 507_214
  end

  defp has_symbol_adjacent?({:number, _, a..b, line}, line_symbol_pos_map) do
    Range.new(a - 1, b + 1)
    |> Enum.any?(fn pos ->
      Enum.any?(-1..1, fn dl ->
        (set = Map.get(line_symbol_pos_map, line + dl)) &&
          MapSet.member?(set, pos)
      end)
    end)
  end

  defp decompose(line_str, line_nr) do
    line_str
    |> String.split(~r/(\.)/, include_captures: true, trim: true)
    |> Enum.flat_map(&String.split(&1, ~r/(\D)/, include_captures: true, trim: true))
    |> Stream.transform(0, fn
      ".", pos -> {[], pos + 1}
      str, pos -> {[tuple_for_thing(str, pos, line_nr)], pos + String.length(str)}
    end)
  end

  defp tuple_for_thing(thing_str, start_pos, line_nr) do
    case Integer.parse(thing_str) do
      {number, ""} ->
        {:number, number, Range.new(start_pos, start_pos + String.length(thing_str) - 1), line_nr}

      :error ->
        1 = String.length(thing_str)
        {:symbol, thing_str, start_pos, line_nr}
    end
  end

  defp symbol_tuple?({:number, _, _, _}), do: false
  defp symbol_tuple?({:symbol, _, _, _}), do: true

  @tag :day3part2
  test "day 3, part 2" do
    things =
      File.read!("data_input/input3.txt")
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {line_str, lix} ->
        decompose(line_str, lix)
      end)

    # map: line_nr => list of number tuples
    line_numbers_map =
      Enum.reject(things, &symbol_tuple?/1)
      |> Enum.group_by(fn {:number, _str, _range, line} -> line end)

    sum =
      things
      |> Enum.filter(&symbol_tuple?/1)
      |> Enum.filter(fn {:symbol, str, _pos, _line} -> str == "*" end)
      |> Enum.filter(fn {:symbol, "*", pos, line} ->
        has_two_numbers_adjacent?(pos, line, line_numbers_map)
      end)
      |> Enum.map(fn {:symbol, "*", pos, line} ->
        multiply_two_numbers_adjacent(pos, line, line_numbers_map)
      end)
      |> Enum.sum()

    assert sum == 72_553_319
  end

  defp has_two_numbers_adjacent?(pos, line, line_numbers_map),
    do: get_numbers_adjacent(pos, line, line_numbers_map) |> length() == 2

  defp get_numbers_adjacent(pos, line, line_numbers_map) do
    Range.new(line - 1, line + 1)
    |> Enum.flat_map(&Map.get(line_numbers_map, &1))
    |> Enum.filter(fn {:number, _n, a..b, _line} -> pos in Range.new(a - 1, b + 1) end)
  end

  defp multiply_two_numbers_adjacent(pos, line, line_numbers_map) do
    [{:number, n, _, _}, {:number, m, _, _}] =
      get_numbers_adjacent(pos, line, line_numbers_map)

    n * m
  end
end
