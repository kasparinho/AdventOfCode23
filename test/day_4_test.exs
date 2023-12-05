defmodule Day4Test do
  use ExUnit.Case

  @tag :day4part1
  test "day 4, part 1" do
    sum =
      File.stream!("data_input/input4.txt")
      |> Enum.map(&n_winners_on_card/1)
      |> Enum.map(&card_score/1)
      |> Enum.sum()

    assert sum == 22897
  end

  def n_winners_on_card(line_str) do
    [_, winners_str, numbers_str] = Regex.run(~r/^Card +\d+:([\d ]+)\|([\d ]+)$/, line_str)

    winner_set =
      String.split(winners_str, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> MapSet.new()

    _n_winning =
      String.split(numbers_str, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.filter(&MapSet.member?(winner_set, &1))
      |> length()
  end

  defp card_score(n) do
    if n == 0,
      do: 0,
      else: :math.pow(2, n - 1) |> trunc()
  end

  @tag :day4part2
  test "day 4, part 2" do
    number_of_cards =
      File.stream!("data_input/input4.txt")
      |> Enum.map(&n_winners_on_card/1)
      |> Enum.with_index()
      |> Enum.reduce({%{}, 0}, fn {n, ix}, {copies_map, count} ->
        n_extra_copies = Map.get(copies_map, ix, 0)
        n_copies = 1 + n_extra_copies

        copies_map_upd =
          if n > 0 do
            Range.new(ix + 1, ix + n)
            |> Map.new(fn i -> {i, n_copies} end)
            |> Map.merge(copies_map, fn _k, v1, v2 -> v1 + v2 end)
          else
            copies_map
          end

        {copies_map_upd, count + n_copies}
      end)
      |> then(fn {_, count} -> count end)

    assert number_of_cards == 5_095_824
  end
end
