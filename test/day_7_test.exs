defmodule Day7Test do
  use ExUnit.Case

  @tag :day7part1
  test "day 7, part 1" do
    assert "32T3K 765" |> parse_line() == {"32T3K", 765}

    assert "32T3K" |> freq() == [2, 1, 1, 1]

    assert "32T3K" |> card_scores(false) == [3, 2, 10, 3, 13]

    sum =
      File.stream!("data_input/input7.txt")
      |> Enum.map(&parse_line/1)
      |> Enum.sort_by(fn {hand, _bid} -> {freq(hand), card_scores(hand, false)} end)
      |> Enum.with_index()
      |> Enum.map(fn {tup, ix} -> {tup, _rank = ix + 1} end)
      |> Enum.map(fn {{_, bid}, rank} -> rank * bid end)
      |> Enum.sum()

    assert sum == 248_217_452
  end

  @tag :day7part2
  test "day 7, part 2" do
    assert "KTJJT" |> freq_with_jokers() == [4, 1]

    sum =
      File.stream!("data_input/input7.txt")
      |> Enum.map(&parse_line/1)
      |> Enum.sort_by(fn {hand, _bid} -> {freq_with_jokers(hand), card_scores(hand, true)} end)
      |> Enum.with_index()
      |> Enum.map(fn {tup, ix} -> {tup, _rank = ix + 1} end)
      |> Enum.map(fn {{_, bid}, rank} -> rank * bid end)
      |> Enum.sum()

    assert sum == 245_576_185
  end

  defp parse_line(str) do
    [_, hand, bid] = Regex.run(~r/^(\S+) (\d+)$/, str)
    {hand, String.to_integer(bid)}
  end

  defp freq(hand) do
    String.splitter(hand, "", trim: true)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
  end

  defp freq_with_jokers(hand) do
    freq_map =
      String.splitter(hand, "", trim: true)
      |> Enum.frequencies()

    n_jokers = Map.get(freq_map, "J", 0)

    freq_map
    |> Map.delete("J")
    |> Map.values()
    |> Enum.sort(:desc)
    # add jokers to the first element
    |> then(fn
      [first | tail] -> [first + n_jokers | tail]
      [] -> [n_jokers]
    end)
  end

  defp card_scores(hand, joker_is_zero?) do
    String.splitter(hand, "", trim: true)
    |> Enum.map(&card_score(&1, joker_is_zero?))
  end

  defp card_score("A", _), do: 14
  defp card_score("K", _), do: 13
  defp card_score("Q", _), do: 12
  defp card_score("J", _joker_is_zero? = false), do: 11
  defp card_score("J", _joker_is_zero? = true), do: 0
  defp card_score("T", _), do: 10
  defp card_score(d, _), do: String.to_integer(d)
end
