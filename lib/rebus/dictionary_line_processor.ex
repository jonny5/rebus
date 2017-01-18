defmodule DictionaryLineProcessor do
  alias Rebus.Word
  alias Rebus.Repo

  # comments start with ;;;
  def process(";;;" <> _, _) do 0 end
  def process(line, common_words) do
    [name, pronunciation] = String.trim(line) |> String.split("  ")

    # remove 0/1/2 from end of strings
    pronunciation = String.replace(pronunciation, ~r/[012]/, "")
    pronunciation_length = String.split(pronunciation) |> Enum.count
    name = name |> String.downcase |> String.replace(~r/\([012345]\)/, "")

    has_image = if common_words[name], do: true, else: false
    process_word(name, pronunciation, pronunciation_length, has_image)
  end

  def process_word(name, pronunciation, pronunciation_length, has_image) do
    existing_word = Repo.get_by(Word, name: name)
    if existing_word do
      existing_word
    else
      changeset = Word.changeset(%Word{}, %{name: name, pronunciation: pronunciation, pronunciation_length: pronunciation_length, has_image: has_image})
      {_, word} = Repo.insert(changeset)
      word
    end
  end
end
