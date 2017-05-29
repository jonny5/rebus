defmodule Rebus.WordNode do
  defstruct [:remainder, :operator, :name, :children, :depth]
  def print(nodes) when is_list(nodes) do
    nodes |>
    Enum.map(&print/1)
  end
  def print(node) do
    cond do
      node.children ->
        responses = Enum.map(node.children, fn(child) -> print(child) end)
        elements = Enum.join(responses, " #{node.operator} ")
        "#{elements}"
      node.name ->
        node.name
      node.remainder ->
        node.remainder
    end
  end
end
