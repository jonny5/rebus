defmodule Rebus.InnerWordFinder do
  import Ecto.Query
  alias Rebus.{Word, Repo, WordNode, StringSubsets}

  def process(text) do
    text
  end

  def find_word(text) do
    responses = all_words_in_text(%{remainder: text}) |>
    Enum.map(fn word ->
      [word] ++ all_words_in_text(word)
    end)
  end

  def all_words_in_text(node) do
    all_words_in_text(node, 0, [])
  end

  def all_words_in_text(node, index, words) do
    string_array = String.split(node.remainder)
    pronunciation_length = length(string_array)

    if index < pronunciation_length do
      found_word = word_from_pronunciation(node.remainder, index)

      if found_word do
        remainder = string_array |> Enum.slice(index + 1..pronunciation_length) |> Enum.join(" ")

        found_node =
          case String.length(remainder) do
            0 ->
              %{remainder: remainder, word: found_word, final: true}
            _ ->
              %{remainder: remainder, word: found_word}
          end

        all_words_in_text(node, index+1, words ++ [found_node])
      else
        all_words_in_text(node, index+1, words)
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
end
