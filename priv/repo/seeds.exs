# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rebus.Repo.insert!(%Rebus.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require DictionaryLineProcessor
defmodule CommonWords do
  def compute do
    case File.read("files/common_words.txt") do
      {:ok, response} ->
        response |> String.split("\n") |> Enum.map(fn(word) -> {word, true} end) |> Map.new
    end
  end
end

IO.puts "started seed words"
common_words_list = CommonWords.compute
File.stream!("files/cmudict.txt", [:utf8]) |> Enum.each(fn line ->
  DictionaryLineProcessor.process(line, common_words_list)
end)



IO.puts "completed seed words"
