defmodule Day1Test do
  use ExUnit.Case

  @tag :day1
  test "day1" do
    sum = File.stream!("data_input/input1.txt")
    |> Stream.map(fn str -> first_digit(str) <> last_digit(str) end)
    |> Stream.map(&String.to_integer/1)
    |> Enum.sum()

    assert sum == 54927
  end

  defp first_digit(str), do: Regex.run(~r/^\D*(\d)/, str) |> then(fn [_, d] -> d end)
  defp last_digit(str), do: Regex.run(~r/(\d)\D*$/, str) |> then(fn [_, d] -> d end)
end
