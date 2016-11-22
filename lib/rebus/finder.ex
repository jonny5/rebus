defmodule Rebus.WordNode do
  defstruct [:remainder, :operator, :word, :children]

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
    pronunciation = input_word.pronunciation
    query = from word in Word,
              where: word.id != ^input_word.id and fragment("(?) ~ (?)", word.pronunciation, ^pronunciation),
              limit: 1
    response = Repo.one(query)
    %WordNode{word: response.name, operator: "+"}
  end
end
