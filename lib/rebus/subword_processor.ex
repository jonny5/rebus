defmodule SubwordProcessor do
  alias Rebus.Word
  alias Rebus.Repo
  alias Rebus.Subword
  alias Rebus.SubwordGroup
  import Ecto.Query

  def process do
    query = from Word
    Repo.all(query)
  end

  def process_word() do
    # existing_word = Repo.get_by(Word, name: name)
  end
end
