defmodule Rebus.InnerWordFinder do
  import Ecto.Query
  alias Rebus.{Word, Repo, WordNode, StringSubsets}

  def process(text) do
    node = text |> word |> word_to_node
    %{ node | children: children(node.remainder, 1), remainder: nil, operator: "+" }
  end

  def word(text) do
    Rebus.Repo.one(
      from word in Word,
      where: word.name == ^text,
      limit: 1
    )
  end

  def children(_, 3) do
    []
  end

  def children(remainder, depth) do
    # remove first element which will be the root value
    [_ | terms] = StringSubsets.compute(remainder)
    response = find_inner_word(terms)
    cond do
      response ->
        response |> word_to_node(depth) |> node_siblings(remainder)
      true ->
        []
    end
  end

  def find_inner_word([]) do
    nil
  end

  def find_inner_word(terms) do
    [ term | tail ] = terms
    response = find_common_word(term)
    cond do
      response ->
        response
      true ->
        find_inner_word(tail)
    end
  end

  def node_siblings(word_node, remainder) do
    [left, right] = String.split(remainder, word_node.remainder, parts: 2)

    [node_from_remainder(left, word_node.depth), word_node, node_from_remainder(right, word_node.depth)]
    |> Enum.filter(fn(child) -> child end)
  end

  def word_to_node(word) do
    %WordNode{name: word.name, operator: nil, depth: 0, remainder: word.pronunciation, children: nil}
  end

  def word_to_node(word, depth) do
    %WordNode{name: word.name, operator: nil, depth: depth, remainder: word.pronunciation, children: nil}
  end

  def node_from_remainder(value, depth) do
    remainder = String.trim(value)
    if String.length(remainder) > 0 do
      word = find_common_word(remainder)
      if word do
        %WordNode{remainder: remainder, name: word.name, depth: depth}
      else
        %WordNode{remainder: remainder, children: children(remainder, depth + 1), operator: "+", depth: depth}
      end
    end
  end

  def find_common_word(pronunciation) do
    Repo.all(
      from word in Word,
      where: word.pronunciation == ^pronunciation and word.has_image == true
    )
    |> word_response
  end

  def word_response([]) do nil end
  def word_response(list) do
    List.first(list)
  end
end
