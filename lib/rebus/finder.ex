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
  def search(%{name: name, pronunciation: pronunciation, pronunciation_length: nil}) do
    query = search [index: "rebus"] do
      query do
        bool do
          must do
            match_phrase "pronunciation", remainder
          end
          must_not do
            term "name", name
          end
          must_not do
            term "pronunciation", remainder
          end
        end
      end
    end

    {_, _, response} = Tirexs.Query.create_resource(query)
    List.first(response.hits.hits)
  end
end

defmodule Rebus.Finder do
  import Ecto.Query
  alias Rebus.{Word, Repo, WordNode}

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
        outer_word = find_outer_word(word_node)
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

  def find_inner_word(%WordNode{name: name, remainder: remainder}) when name != nil do
    Repo.one(
      from word in Word,
      where: word.name != ^name and word.pronunciation != ^remainder and fragment("(?) ~ (?)", ^remainder, word.pronunciation),
      order_by: fragment("similarity(?, ?) DESC", word.pronunciation, ^remainder),
      limit: 1
    )
  end

  def find_inner_word(%WordNode{remainder: remainder}) do
    Repo.one(
      from word in Word,
      where: word.pronunciation != ^remainder and fragment("(?) ~ (?)", ^remainder, word.pronunciation),
      order_by: fragment("similarity(?, ?) DESC", word.pronunciation, ^remainder),
      limit: 1
    )
  end

  def find_outer_word(%WordNode{name: name, remainder: remainder}) when name != nil do
    Repo.one(
      from word in Word,
      where: word.name != ^name and word.pronunciation != ^remainder and fragment("(?) ~ (?)", word.pronunciation, ^remainder),
      order_by: fragment("similarity(?, ?) DESC", word.pronunciation, ^remainder),
      limit: 1
    )
  end

  def find_outer_word(%WordNode{remainder: remainder}) do
    Repo.one(
      from word in Word,
      where: word.pronunciation != ^remainder and fragment("(?) ~ (?)", word.pronunciation, ^remainder),
      order_by: fragment("similarity(?, ?) DESC", word.pronunciation, ^remainder),
      limit: 1
    )
  end

  def find_word(pronunciation) do
    Repo.one(
      from word in Word,
      where: word.pronunciation == ^pronunciation,
      limit: 1
    )
  end
end
