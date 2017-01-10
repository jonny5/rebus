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
        [ term: [ has_image: true] ]
      ],
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
