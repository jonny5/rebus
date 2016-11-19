defmodule DictionaryLineProcessor do
  alias Rebus.Word
  alias Rebus.Repo

  # comments start with ;;;
  def process(";;;" <> _) do 0 end
  def process(line) do
    [name, pronunciation] = String.trim(line) |> String.split("  ")
    pronunciation_length = String.split(pronunciation) |> Enum.count
    name = String.downcase(name) |> name_or_nil
    changeset = Word.changeset(%Word{}, %{name: name, pronunciation: pronunciation, pronunciation_length: pronunciation_length})
    if changeset.valid? do
      Repo.insert(changeset)
    end
  end

  def name_or_nil(name) do
    if (Repo.get_by(Word, name: name)), do: nil, else: name
  end
end
