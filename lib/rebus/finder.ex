defmodule Rebus.WordNode do
  defstruct [:remainder, :operator, :word_id, :children, :parent]

  def print(node) do
    cond do
      node.children ->
        responses = Enum.map(node.children, fn(child) -> print(child) end)
        elements = Enum.join(responses, " #{node.operator} ")
        "(#{elements})"
      node.word ->
        node.word
    end
  end
end

defmodule Rebus.Finder do
  import Ecto.Query
  alias Rebus.{Word, Repo, WordNode, WordTree}

  def process(input_word) do
    parent_node = %WordNode{word_id: nil, operator: nil, parent: nil, remainder: input_word.pronunciation  }
    %{ parent_node | children: process_node(parent_node) }
  end

  def process_node(word_node) do
    if word_node.word_id do
      word_node
    else
      matching_word_node = find_contained_word(word_node)
      remainders = word_node.remainder.split(matching_word_node.remainder)
      first_remainder = remainders
      |> List.first
      |> String.trim
      if String.length(first_remainder) > 0 do
        node = process_node(%WordNode{word_id: find_word(first_remainder).id, parent: word_node, remainder: first_remainder})
        List.insert_at(children, 0, node)
      end

      second_remainder = remainders
      |> List.last
      |> String.trim
      if String.length(second_remainder) > 0 do
        node = process_node(%WordNode{word_id: find_word(second_remainder).id, parent: word_node, remainder: second_remainder})
        List.insert_at(children, 2, node)
      end

      %{ word_node | children: children, operator: "+" }
    end
  end

  def find_contained_word_node(word_node) do
    response = Repo.one(
                  from word in Word,
                  where: word.id != ^input_word.id and fragment("(?) ~ (?)", word.pronunciation, ^pronunciation),
                  limit: 1
               )
    %WordNode{word_id: response.id, parent: word_node, remainder: response.pronunciation}
  end

  def find_word(pronunciation) do
    Repo.one(
      from word in Word,
      where: word.pronunciation == ^pronunciation,
      limit: 1
    )
  end
end
