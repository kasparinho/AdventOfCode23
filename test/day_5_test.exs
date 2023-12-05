defmodule Day5Test do
  use ExUnit.Case

  @tag :day5part1
  test "day 5, part 1" do
    full_str = File.read!("data_input/input5.txt")
    [seed_line_str | parts] = String.split(full_str, "\n\n")

    mapper_fun_list = Enum.map(parts, &mapper_fun/1)

    min_location =
      seeds(seed_line_str)
      |> Enum.map(fn s ->
        Enum.reduce(mapper_fun_list, _acc = s, fn fun, acc -> fun.(acc) end)
      end)
      |> Enum.min()

    assert min_location == 31_599_214
  end

  @tag :day5part2
  @tag timeout: :infinity
  test "day 5, part 2" do
    full_str = File.read!("data_input/input5.txt")
    [seed_line_str | parts] = String.split(full_str, "\n\n")

    mapper_fun_list = Enum.map(parts, &mapper_fun/1)

    min_location =
      seeds_part2(seed_line_str)
      |> Flow.from_enumerable()
      |> Flow.map(fn s ->
        Enum.reduce(mapper_fun_list, _acc = s, fn fun, acc -> fun.(acc) end)
      end)
      |> Enum.min()

    assert min_location == 20_358_599
  end

  defp seeds(seed_line_str),
    do:
      Regex.scan(~r/ (\d+)/, seed_line_str)
      |> Enum.map(fn [_, s] -> String.to_integer(s) end)

  defp seeds_part2(seed_line_str),
    do:
      seeds(seed_line_str)
      |> Enum.chunk_every(2, 2)
      |> Stream.flat_map(fn [a, l] ->
        range(a, l)
        |> IO.inspect()
        |> Enum.to_list()
      end)

  defp mapper_fun(part_str) do
    tuples =
      String.split(part_str, "\n")
      |> Enum.flat_map(fn line_str ->
        case Regex.run(~r/(\d+) (\d+) (\d+)/, line_str) do
          [_, a, b, c] -> [{String.to_integer(a), String.to_integer(b), String.to_integer(c)}]
          nil -> []
        end
      end)

    fn source ->
      Enum.find(tuples, fn {_dest_start, source_start, range_length} ->
        source in range(source_start, range_length)
      end)
      |> case do
        {dest_start, source_start, _range_length} -> source - source_start + dest_start
        nil -> source
      end
    end
  end

  defp range(start, length), do: start..(start + length - 1)
end
