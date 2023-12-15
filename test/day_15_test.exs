defmodule Day15Test do
  use ExUnit.Case

  @tag :day15
  test "day 15" do
    ## part 1
    assert hash("HASH") == 52

    assert "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
           |> sum_of_hashes() == 1320

    assert File.read!("data_input/input15.txt")
           |> sum_of_hashes() == 504_449

    ## part 2

    assert "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
           |> focusing_power_sum() == 145

    assert File.read!("data_input/input15.txt")
           |> focusing_power_sum() == 262_044
  end

  defp focusing_power_sum(str) do
    box_map =
      str
      |> String.split(",")
      |> Enum.reduce(%{}, fn step_str, box_map -> box_update(box_map, step_str) end)

    box_map
    |> Enum.map(fn {box, tuples} -> box_score(box, tuples) end)
    |> Enum.sum()
  end

  defp box_score(box, tuples) do
    tuples
    |> Enum.with_index()
    |> Enum.map(fn {{_label, fl}, ix} -> (ix + 1) * (box + 1) * fl end)
    |> Enum.sum()
  end

  defp box_update(box_map, step_str) do
    case Regex.run(~r/^(\D+)=(\d)$/, step_str) do
      [_, label, focal_length_str] ->
        box = hash(label)
        fl = String.to_integer(focal_length_str)

        if box_has_label?(box_map, box, label) do
          Map.update!(
            box_map,
            box,
            &Enum.map(&1, fn
              {^label, _} -> {label, fl}
              tup -> tup
            end)
          )
        else
          Map.update(box_map, box, [{label, fl}], &(&1 ++ [{label, fl}]))
        end

      nil ->
        [_, label] = Regex.run(~r/^(\D+)-$/, step_str)
        box = hash(label)

        if box_has_label?(box_map, box, label) do
          Map.update!(box_map, box, &Enum.reject(&1, fn {l, _} -> l == label end))
        else
          box_map
        end
    end
  end

  defp box_has_label?(box_map, box, label),
    do: Map.get(box_map, box, []) |> Enum.any?(fn {l, _} -> l == label end)

  defp sum_of_hashes(str) do
    str
    |> String.split(",")
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  defp hash(str) do
    String.to_charlist(str)
    |> Enum.reduce(0, fn c, acc ->
      ((acc + c) * 17)
      |> rem(256)
    end)
  end
end
