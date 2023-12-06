defmodule Day6Test do
  use ExUnit.Case

  @times [40_709_879]
  @distances [215_105_121_471_005]

  @tag :day6part2
  test "day 6, part 2" do
    possibilities =
      Enum.zip(@times, @distances)
      |> Enum.map(fn {n, c} ->
        lb = ceil((n - :math.sqrt(n * n - 4 * c)) / 2.0)
        ub = floor((n + :math.sqrt(n * n - 4 * c)) / 2.0)
        ub - lb + 1
      end)
      |> Enum.reduce(1, fn m, p -> m * p end)

    assert possibilities == 28_228_952
  end
end
