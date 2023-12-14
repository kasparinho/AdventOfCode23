defmodule Day9Test do
  use ExUnit.Case

  @tag :day9part1
  test "day 9, part 1" do
    assert "0 3 6 9 12 15" |> parse_line() |> stack_diff_lists() |> next_value() == 18
    assert "1 3 6 10 15 21" |> parse_line() |> stack_diff_lists() |> next_value() == 28
    assert "10 13 16 21 30 45" |> parse_line() |> stack_diff_lists() |> next_value() == 68

    sum =
      File.stream!("data_input/input9.txt")
      |> Enum.map(&parse_line/1)
      |> Enum.map(&stack_diff_lists/1)
      |> Enum.map(&next_value/1)
      |> Enum.sum()

    assert sum == 1_762_065_988
  end

  @tag :day9part2
  test "day 9, part 2" do
    assert "0 3 6 9 12 15" |> parse_line() |> stack_diff_lists() |> prev_value() == -3
    assert "1 3 6 10 15 21" |> parse_line() |> stack_diff_lists() |> prev_value() == 0
    assert "10 13 16 21 30 45" |> parse_line() |> stack_diff_lists() |> prev_value() == 5

    sum =
      File.stream!("data_input/input9.txt")
      |> Enum.map(&parse_line/1)
      |> Enum.map(&stack_diff_lists/1)
      |> Enum.map(&prev_value/1)
      |> Enum.sum()

    assert sum == 1_762_065_988
  end

  defp prev_value(stack) do
    assert stops_with_zeros?(stack)

    Enum.map(stack, fn numbers -> Enum.at(numbers, 0) end)
    |> Enum.reduce(0, fn d, acc -> d - acc end)
  end

  defp next_value(stack) do
    assert stops_with_zeros?(stack)

    Enum.map(stack, fn numbers -> Enum.at(numbers, -1) end)
    |> Enum.sum()
  end

  defp stops_with_zeros?(_stack = [[_single] | _]), do: false
  defp stops_with_zeros?(_stack = [_numbers | _]), do: true

  defp stack_diff_lists(numbers), do: stack_diff_lists_rec([numbers])

  defp stack_diff_lists_rec(stack = [numbers | _tail]) do
    if is_constant?(numbers),
      do: stack,
      else: [diff_list(numbers) | stack] |> stack_diff_lists_rec()
  end

  defp diff_list(numbers) do
    Enum.chunk_every(numbers, 2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

  defp is_constant?(numbers) do
    MapSet.new(numbers) |> MapSet.size() == 1
  end

  defp parse_line(str) do
    Regex.scan(~r/(-?\d+)/, str)
    |> Enum.map(fn [_, n_str] -> String.to_integer(n_str) end)
  end
end
