defmodule Day2Test do
  use ExUnit.Case

  @tag :day2part1
  test "day 2, part 1" do
    sum =
      File.stream!("data_input/input2.txt")
      |> Stream.reject(fn str ->
        max_for_color(str, "red") > 12 or max_for_color(str, "green") > 13 or
          max_for_color(str, "blue") > 14
      end)
      |> Enum.map(fn str -> game_nr(str) end)
      |> Enum.sum()

    assert sum == 2283
  end

  @tag :day2part2
  test "day 2, part 2" do
    sum =
      File.stream!("data_input/input2.txt")
      |> Stream.map(fn str ->
        max_for_color(str, "red") * max_for_color(str, "green") * max_for_color(str, "blue")
      end)
      |> Enum.sum()

    assert sum == 78669
  end

  defp max_for_color(str, color_str) do
    String.split(str, ";")
    |> Enum.map(fn substr ->
      case Regex.run(~r/ (\d+) #{color_str}/, substr) do
        [_, n_str] -> String.to_integer(n_str)
        nil -> 0
      end
    end)
    |> Enum.max()
  end

  defp game_nr(str),
    do:
      Regex.run(~r/Game (\d+):/, str)
      |> then(fn [_, game_nr_str] -> String.to_integer(game_nr_str) end)
end
