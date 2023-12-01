defmodule Day1Test do
  use ExUnit.Case

  @tag :day1
  test "day1" do
    sum =
      File.stream!("data_input/input1.txt")
      |> Stream.map(fn str -> first_digit(str) <> last_digit(str) end)
      |> Stream.map(&String.to_integer/1)
      |> Enum.sum()

    assert sum == 54581
  end

  @digits_as_string %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  defp first_digit(str), do: find_digit(str, _reverse? = false)
  defp last_digit(str), do: find_digit(str, _reverse? = true)

  defp find_digit(str, reverse?),
    do:
      regex_expr(reverse?)
      |> Regex.run(reverse_if_needed(str, reverse?))
      |> then(fn [_, d] -> Map.get(@digits_as_string, reverse_if_needed(d, reverse?)) || d end)

  defp regex_expr(reverse?) do
    digits =
      Map.keys(@digits_as_string)
      |> Enum.map(&reverse_if_needed(&1, reverse?))
      |> Enum.join("|")

    ~r/(\d|#{digits})/
  end

  defp reverse_if_needed(str, _reverse? = false), do: str
  defp reverse_if_needed(str, _reverse? = true), do: String.reverse(str)
end
