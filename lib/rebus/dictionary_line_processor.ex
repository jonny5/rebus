defmodule DictionaryLineProcessor do
  alias Rebus.Word
  alias Rebus.Repo
  import Tirexs.HTTP

  # comments start with ;;;
  def process(";;;" <> _) do 0 end
  def process(line) do
    [name, pronunciation] = String.trim(line) |> String.split("  ")

    # remove 0/1/2 from end of strings
    pronunciation = String.replace(pronunciation, ~r/[012]/, "")
    pronunciation_length = String.split(pronunciation) |> Enum.count
    name = String.downcase(name)
    word = process_word(name, pronunciation, pronunciation_length)
    put("/rebus/words/#{word.id}", [name: name, pronunciation: pronunciation, pronunciation_length: pronunciation_length])
  end

  def process_word(name, pronunciation, pronunciation_length) do
    existing_word = Repo.get_by(Word, name: name)
    if existing_word do
      existing_word
    else
      changeset = Word.changeset(%Word{}, %{name: name, pronunciation: pronunciation, pronunciation_length: pronunciation_length})
      Repo.insert(changeset)
    end
  end
end
