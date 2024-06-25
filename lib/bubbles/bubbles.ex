defmodule Bubbles.Bubbles do
  def generate(length) do
    List.duplicate(false, length) |> Enum.map(fn _x -> List.duplicate(false, length) end)
  end

  def update_bubble(bubbles, column, row) do
    List.update_at(
      bubbles,
      column,
      &List.update_at(&1, row, fn _ -> true end)
    )
  end

  def get_rand(bubbles) do
    {column, column_index} = Enum.random(bubbles)
    {_, row_index} = Enum.random(column)
    {column_index, row_index}
  end
end
