defmodule Rebus.InnerWordFinder do
  import Ecto.Query
  alias Rebus.{Word, Repo, WordNode, StringSubsets}

  def process(text) do
    text
  end

  def find_word(text) do
    find_word(text, 0, [])
  end

  def find_word(text, index, words) do
    IO.puts text
    IO.puts index


    string_array = String.split(text)
    pronunciation_length = length(string_array)
    IO.puts "LENGTHS"
    IO.puts index
    IO.puts pronunciation_length
    if index + 1 < pronunciation_length do
      found_word = word_from_pronunciation(text, index)

      if found_word do
        # remainder = string_array |> Enum.slice(index + 1..pronunciation_length) |> Enum.join(" ")
        # IO.puts "REMAINDER"
        # IO.puts remainder
        find_word(text, index+1, words ++ [found_word])
      else
        find_word(text, index+1, words)
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
