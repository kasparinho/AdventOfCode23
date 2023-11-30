defmodule AdventOfCode23Web.ErrorJSONTest do
  use AdventOfCode23Web.ConnCase, async: true

  test "renders 404" do
    assert AdventOfCode23Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AdventOfCode23Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
