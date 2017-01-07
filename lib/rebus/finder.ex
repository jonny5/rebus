require IEx

defmodule Rebus.WordNode do
  defstruct [:remainder, :operator, :name, :children, :depth]

  def print(node) do
    cond do
      node.children ->
        responses = Enum.map(node.children, fn(child) -> print(child) end)
        elements = Enum.join(responses, " #{node.operator} ")
        "(#{elements})"
      node.name ->
        node.name
      node.remainder ->
        node.remainder
    end
  end
end

defmodule Rebus.WordNodeSearch do
  alias Rebus.WordNode

  def search(word_node) do

    word_node
    |> search_params
    |> elastic_search
  end

  def search_params(%WordNode{name: name, remainder: remainder} = word_node, params \\ []) do
    cond do
      name ->
        search_params(%{ word_node | name: nil }, name_params(name) ++ params)
      remainder ->
        search_params(%{ word_node | remainder: nil }, remainder_params(remainder) ++ params)
      true ->
        params
    end
  end

  def name_params(name) do
    [ must_not: [ term: [ name: name ] ] ]
  end

  def remainder_params(remainder) do
    [
      must: [
        [ match_phrase: [ pronunciation: remainder] ]
      ],
      must_not: [
        [ term: [ pronunciation_length: remainder |> String.split |> Enum.count] ]
      ],
    ]
  end

  def elastic_search(bool_params) do
    query = [
      index: "rebus",
      search: [
        query: [
          bool: bool_params
        ]
      ]
    ]
    process_query(query)
  end

  def process_query(query) do
    {_, _, response} = Tirexs.Query.create_resource(query)
    response.hits.hits |> List.first |> response_source
  end

  def response_source(nil), do: nil
  def response_source(hit), do: hit._source
end

defmodule Rebus.Finder do
  import Ecto.Query
  alias Rebus.{Word, Repo, WordNode, WordNodeSearch, StringSubsets}

  def process(input_word) do
    parent_node = %WordNode{name: input_word.name, operator: nil, depth: 0, remainder: input_word.pronunciation, children: nil}

    process_node(parent_node)
  end

  def process_node(%WordNode{name: name, depth: depth} = node) when name != nil and depth != 0 do
    node
  end
  # give up after 5
  def process_node(%WordNode{depth: 5} = node) do node end
  def process_node(%WordNode{remainder: nil} = node) do node end

  def process_node(%WordNode{remainder: remainder, depth: depth} = word_node) do
    found_word = find_word(remainder)

    if (depth != 0 && found_word) do
      process_node(%{ word_node | name: found_word.name, remainder: nil, depth: (depth + 1) })
    else
      case find_next_node(word_node) do
        {:fail, _} ->
          process_node(%{ word_node | depth: 5 })
        {operator, next_node} ->
          process_node(%{ word_node | children: node_siblings(next_node, operator, remainder, depth), depth: (depth + 1), operator: operator, remainder: nil })
      end
    end
  end

  def find_next_node(word_node) do
    find_next_node(word_node, '+')
  end

  def find_next_node(word_node, operator) do
    case(operator) do
      '+' ->
        inner_node = find_inner_word(word_node)
        if inner_node && inner_node.name, do: {operator, inner_node}, else: find_next_node(word_node, '-')
      '-' ->
         outer_node = WordNodeSearch.search(word_node)
         if outer_node && outer_node.name, do: {operator, outer_node}, else: find_next_node(word_node, nil)
      nil ->
        {:fail, nil}
    end
  end

  def node_siblings(word_node, remainder, depth) do
    matching_node = %WordNode{remainder: nil, name: word_node.name}
    [first, second] = if String.length(remainder) > String.length(word_node.pronunciation), do: [remainder, word_node.pronunciation], else: [word_node. pronunciation, remainder]
    [left, right] = String.split(first, second, parts: 2)

    [node_from_remainder(left), matching_node, node_from_remainder(right)]
    |> Enum.filter(fn(child) -> child end)
    |> Enum.map(fn(child) -> process_node( %{ child | depth: (depth + 1) } )   end)
  end

  def node_from_remainder(value) do
    remainder = String.trim(value)

    if String.length(remainder) > 0 do
      %WordNode{remainder: remainder}
    end
  end

  def find_inner_word(%WordNode{remainder: remainder}) do
    [_ | terms] = StringSubsets.compute(remainder)
    find_inner_word(terms)
  end

  def find_inner_word([]) do
    nil
  end

  def find_inner_word(terms) do
    [ head | tail ] = terms

    response = find_word(head)
    cond do
      response ->
        response
      true ->
        find_inner_word(tail)
    end
  end

  def find_word(pronunciation) do
    Repo.one(
      from word in Word,
      where: word.pronunciation == ^pronunciation,
      limit: 1
    )
  end
end
