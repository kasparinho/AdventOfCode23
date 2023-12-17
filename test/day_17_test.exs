defmodule Day17Test do
  use ExUnit.Case

  @tag :day17
  test "day 17" do
    ## part 1
    board_map =
      File.read!("data_input/input17.txt")
      |> board_map()

    assert shortest_path(board_map, 1..3) == 686

    ## part 2
    assert shortest_path(board_map, 4..10) == 801
  end

  defp shortest_path(board_map, step_range) do
    board_size = {_max_x, _max_y} = board_size(board_map)

    heap =
      expand_start(board_map, step_range)
      |> Enum.into(Heap.min())

    shortest_path_rec(heap, MapSet.new(), board_map, board_size, step_range)
  end

  # heap contains tuples {cost, {x, y, dir}}

  defp shortest_path_rec(heap, closed_set, board_map, board_size, step_range) do
    {tuple = {cost, {x, y, dir}}, heap_tail} = Heap.split(heap)

    IO.inspect(tuple)

    cond do
      {x, y} == board_size ->
        cost

      {x, y, dir} in closed_set ->
        shortest_path_rec(heap_tail, closed_set, board_map, board_size, step_range)

      true ->
        expand(tuple, closed_set, board_map, step_range)
        |> Enum.reduce(heap_tail, fn tup, heap -> Heap.push(heap, tup) end)
        |> shortest_path_rec(
          MapSet.put(closed_set, {x, y, dir}),
          board_map,
          board_size,
          step_range
        )
    end
  end

  defp expand({cost, {x, y, dir}}, closed_set, board_map, step_range) do
    cond do
      dir in [:up, :down] ->
        expand_one_direction(x, y, :right, cost, board_map, closed_set, step_range) ++
          expand_one_direction(x, y, :left, cost, board_map, closed_set, step_range)

      dir in [:right, :left] ->
        expand_one_direction(x, y, :up, cost, board_map, closed_set, step_range) ++
          expand_one_direction(x, y, :down, cost, board_map, closed_set, step_range)

      dir == :start ->
        expand_one_direction(x, y, :right, cost, board_map, closed_set, step_range) ++
          expand_one_direction(x, y, :down, cost, board_map, closed_set, step_range)
    end
  end

  defp expand_one_direction(x, y, dir, cost, board_map, closed_set, step_range) do
    Enum.map(step_range, fn i ->
      {next_step(x, y, dir, i),
       _all_steps = for(i_part <- 1..i, do: next_step(x, y, dir, i_part))}
    end)
    |> Enum.reject(fn {step, _all_steps} -> MapSet.member?(closed_set, step) end)
    |> Enum.filter(fn {{x, y, _dir}, _all_steps} -> Map.has_key?(board_map, {x, y}) end)
    |> Enum.map(fn {step, all_steps} ->
      c =
        Enum.map(all_steps, fn {x, y, _dir} -> Map.fetch!(board_map, {x, y}) end)
        |> Enum.sum()

      {cost + c, step}
    end)
  end

  defp next_step(x, y, :right, i), do: {x + i, y, :right}
  defp next_step(x, y, :left, i), do: {x - i, y, :left}
  defp next_step(x, y, :up, i), do: {x, y - i, :up}
  defp next_step(x, y, :down, i), do: {x, y + i, :down}

  defp expand_start(board_map, step_range) do
    expand({0, {0, 0, :start}}, MapSet.new(), board_map, step_range)
  end

  defp board_size(board_map) do
    Map.keys(board_map) |> Enum.max()
  end

  defp board_map(full_str) do
    String.split(full_str, "\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line_str, y} ->
      String.split(line_str, "", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {single_str, x} -> {{x, y}, String.to_integer(single_str)} end)
    end)
    |> Map.new()
  end
end
