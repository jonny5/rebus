defmodule Rebus.InnerWordFinder do
  import Ecto.Query
  alias Rebus.{Word, Repo, WordNode, StringSubsets}

  def process(text) do
    word = find_word_by_name(text)
    print_word_tree(word.pronunciation)
  end

  def print_word_tree(text) do
    find_word(text) |> flatten_nodes
  end

  def flatten_nodes(nodes, val \\ []) do
    Enum.map(nodes, fn(node) ->
      flatten_node(node, val)
    end)
  end

  def flatten_node(node, val \\ []) do
    if length(node.children) > 0 do
      flatten_nodes(node.children, val ++ [node.word])
    else
      val ++ [node.word]
    end
  end

  def find_word(text) do
    inner_words_from_pronunciation(%{remainder: text})
  end

  def inner_words_from_pronunciation(node) do
    inner_words_from_pronunciation(node, 0, [])
  end

  def inner_words_from_pronunciation(node, index, words) do
    string_array = String.split(node.remainder)
    pronunciation_length = length(string_array)

    if index < pronunciation_length do
      found_word = word_from_pronunciation(node.remainder, index)

      if found_word do
        remainder = string_array |> Enum.slice(index + 1..pronunciation_length) |> Enum.join(" ")
        found_node =
          case String.length(remainder) do
            0 ->
              %{remainder: remainder, word: found_word, children: []}
            _ ->
              %{remainder: remainder, word: found_word, children: find_word(remainder)}
          end

        inner_words_from_pronunciation(node, index+1, words ++ [found_node])
      else
        inner_words_from_pronunciation(node, index+1, words)
      end
    else
      words
    end
  end

  def word_from_pronunciation(pronunciation, index) when is_list(pronunciation) do
    pronunciation |> Enum.slice(0..index) |> Enum.join(" ") |> find_word_by_pronunciation
  end

  def word_from_pronunciation(pronunciation, index) when is_binary(pronunciation) do
    pronunciation |> String.split |> Enum.slice(0..index) |> Enum.join(" ") |> find_word_by_pronunciation
  end

  def find_word_by_pronunciation(pronunciation) do
    Rebus.Repo.one(
      from word in Word,
      where: word.pronunciation == ^pronunciation,
      limit: 1
    )
  end

  def find_word_by_name(name) do
    Rebus.Repo.one(
      from word in Word,
      where: word.name == ^name,
      limit: 1
    )
  end
end
