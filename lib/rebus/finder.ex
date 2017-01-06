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
    IO.inspect(process_query(query))
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
      inner_word = find_inner_word(word_node)
      if inner_word && inner_word.name do
        matching_node = %WordNode{remainder: nil, name: inner_word.name}
        remainders = String.split(remainder, inner_word.pronunciation)

        first_remainder = node_from_remainder(remainders, &List.first/1)
        second_remainder = node_from_remainder(remainders, &List.last/1)

        children = [first_remainder, matching_node, second_remainder]
        |> Enum.filter(fn(child) -> child end)
        |> Enum.map(fn(child) -> process_node( %{ child | depth: (depth + 1) } )   end)

        process_node(%{ word_node | children: children, depth: (depth + 1), operator: "+", remainder: nil })
      else
        outer_word = WordNodeSearch.search(word_node)
        if outer_word && outer_word.name do
          matching_node = %WordNode{remainder: nil, name: outer_word.name}
          remainders = String.split(outer_word.pronunciation, remainder)

          first_remainder = node_from_remainder(remainders, &List.first/1)
          second_remainder = node_from_remainder(remainders, &List.last/1)

          children = [matching_node, first_remainder, second_remainder]
          |> Enum.filter(fn(child) -> child end)
          |> Enum.map(fn(child) -> process_node( %{ child | depth: (depth + 1) } )   end)

          process_node(%{ word_node | children: children, depth: (depth + 1), operator: "-", remainder: nil })
        else
          process_node(%{ word_node | depth: 5 })
        end
      end
    end
  end

  def node_from_remainder(remainders, fun) do
    remainder = fun.(remainders)
    |> String.trim

    if String.length(remainder) > 0 do
      %WordNode{remainder: remainder}
    end
  end

  def find_inner_word(%WordNode{remainder: remainder}) do
    [_ | terms] = StringSubsets.compute(remainder)
    find_inner_word(terms, remainder |> String.split |> Enum.count )
  end

  def find_inner_word([], _) do
    nil
  end

  def find_inner_word(terms, length) do
    [ head | tail ] = terms

    response = find_word(head)
    cond do
      response ->
        response
      true ->
        find_inner_word(tail, length)
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
