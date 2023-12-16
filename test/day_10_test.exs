defmodule Day10Test do
  use ExUnit.Case

  @tag :day10
  test "day 10" do
    # part 1
    board_map =
      File.read!("data_input/input10.txt")
      |> board_map()

    pipe_list = pipe_list(board_map)

    n = length(pipe_list)
    d = n / 2

    assert d == 7093

    # part 2
    assert count_inside(pipe_list) == 407
  end

  defp count_inside(pipe_list) do
    pipe_list
    |> Enum.reverse()
    |> then(fn list -> list ++ [hd(list)] end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [{x, y, dir, _}, {_, _, next_dir, _}] -> {dir, x, y, next_dir} end)
    |> Enum.group_by(fn {_dir, _x, y, _next_dir} -> y end)
    |> Enum.map(fn {_y, tiles} ->
      tiles
      |> Enum.sort_by(fn {_dir, x, _y, _next_dir} -> x end)
      |> Enum.filter(fn {dir, _x, _y, next_dir} ->
        dir in [:up, :down] or next_dir in [:up, :down]
      end)
      |> Enum.reduce({_count = 0, _in_out = :out, _last_dir = :irr}, fn
        {:down, x, _y, :down}, {acc_count, :out, :irr} ->
          {acc_count - x, :in, :irr}

        {:down, x, _y, :down}, {acc_count, :in, :irr} ->
          {acc_count + (x - 1), :out, :irr}

        {:up, x, _y, :up}, {acc_count, :out, :irr} ->
          {acc_count - x, :in, :irr}

        {:up, x, _y, :up}, {acc_count, :in, :irr} ->
          {acc_count + (x - 1), :out, :irr}

        # up_down -> right

        {up_down, _x, _y, :right}, {acc_count, :out, :irr}
        when up_down in [:up, :down] ->
          {acc_count, :out_b, up_down}

        {up_down, x, _y, :right}, {acc_count, :in, :irr}
        when up_down in [:up, :down] ->
          {acc_count + (x - 1), :in_b, up_down}

        # right -> up_down

        {:right, x, _y, up_down}, {acc_count, :out_b, up_down}
        when up_down in [:up, :down] ->
          {acc_count - x, :in, :irr}

        {:right, _x, _y, up_down}, {acc_count, :out_b, up_down_acc}
        when up_down_acc in [:up, :down] and up_down in [:up, :down] ->
          {acc_count, :out, :irr}

        {:right, _x, _y, up_down}, {acc_count, :in_b, up_down}
        when up_down in [:up, :down] ->
          {acc_count, :out, :irr}

        {:right, x, _y, up_down}, {acc_count, :in_b, up_down_acc}
        when up_down_acc in [:up, :down] and up_down in [:up, :down] ->
          {acc_count - x, :in, :irr}

        # up_down <- left

        {:left, x, _y, up_down}, {acc_count, :in, :irr}
        when up_down in [:up, :down] ->
          {acc_count + (x - 1), :in_b, up_down}

        {:left, _x, _y, up_down}, {acc_count, :out, :irr}
        when up_down in [:up, :down] ->
          {acc_count, :out_b, up_down}

        # left <- up_down

        {up_down, _x, _y, :left}, {acc_count, :in_b, up_down}
        when up_down in [:up, :down] ->
          {acc_count, :out, :irr}

        {up_down, x, _y, :left}, {acc_count, :in_b, up_down_acc}
        when up_down in [:up, :down] and up_down_acc in [:up, :down] ->
          {acc_count - x, :in, :irr}

        {up_down, x, _y, :left}, {acc_count, :out_b, up_down}
        when up_down in [:up, :down] ->
          {acc_count - x, :in, :irr}

        {up_down, _x, _y, :left}, {acc_count, :out_b, up_down_acc}
        when up_down in [:up, :down] and up_down_acc in [:up, :down] ->
          {acc_count, :out, :irr}
      end)
      |> then(fn {count, :out, :irr} -> count end)
    end)
    |> Enum.sum()
  end

  defp pipe_list(board_map) do
    {start_x, start_y} = find_start(board_map)

    _first =
      {x, y, dir} =
      [
        {start_x, start_y - 1, :up},
        {start_x, start_y + 1, :down},
        {start_x + 1, start_y, :right},
        {start_x - 1, start_y, :left}
      ]
      |> Enum.find(fn {x, y, dir} ->
        tile = Map.fetch!(board_map, {x, y})
        next_tile({x, y, dir}, tile) != :nono
      end)

    pipe_list_recursive(board_map, {x, y, dir}, [], 1)
  end

  defp pipe_list_recursive(board_map, {x, y, dir}, pipe_list, n) do
    tile = Map.fetch!(board_map, {x, y})

    if tile == "S" do
      [{x, y, dir, n} | pipe_list]
    else
      next = next_tile({x, y, dir}, tile)
      pipe_list_recursive(board_map, next, [{x, y, dir, n} | pipe_list], n + 1)
    end
  end

  defp next_tile({x, y, :up}, "|"), do: {x, y - 1, :up}
  defp next_tile({x, y, :down}, "|"), do: {x, y + 1, :down}
  defp next_tile({x, y, :right}, "-"), do: {x + 1, y, :right}
  defp next_tile({x, y, :left}, "-"), do: {x - 1, y, :left}

  defp next_tile({x, y, :down}, "L"), do: {x + 1, y, :right}
  defp next_tile({x, y, :left}, "L"), do: {x, y - 1, :up}
  defp next_tile({x, y, :down}, "J"), do: {x - 1, y, :left}
  defp next_tile({x, y, :right}, "J"), do: {x, y - 1, :up}
  defp next_tile({x, y, :up}, "7"), do: {x - 1, y, :left}
  defp next_tile({x, y, :right}, "7"), do: {x, y + 1, :down}
  defp next_tile({x, y, :up}, "F"), do: {x + 1, y, :right}
  defp next_tile({x, y, :left}, "F"), do: {x, y + 1, :down}

  defp next_tile(_, _), do: :nono

  defp find_start(board_map) do
    Enum.find(board_map, fn {{_x, _y}, tile} -> tile == "S" end)
    |> then(fn {{x, y}, "S"} -> {x, y} end)
  end

  defp board_map(full_str) do
    String.split(full_str, "\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line_str, y} ->
      String.split(line_str, "", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {single_str, x} -> {{x, y}, single_str} end)
    end)
    |> Map.new()
  end
end
