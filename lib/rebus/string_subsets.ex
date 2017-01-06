defmodule Rebus.StringSubsets do
  def compute(string) do
    list = String.split(string)
    compute(list, [], length(list) - 1, length(list) - 1)
  end

  defp compute(list, subsets, 0, 0) do
    subsets ++ [Enum.slice(list, 0..0)]
    |> Enum.sort_by(&length/1)
    |> Enum.reverse
    |> Enum.map(fn(x) -> Enum.join(x, " "); end)
  end

  defp compute(list, subsets, 0, index2) do
    compute(list, subsets ++ [Enum.slice(list, 0..index2)], index2 - 1, index2 - 1 )
  end

  defp compute(list, subsets, index1, index2) do
    compute(list, subsets ++ [Enum.slice(list, index1..index2)], index1 - 1, index2 )
  end
end
