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

IO.puts "started seed words"
  File.stream!("files/cmudict.txt", [:utf8]) |> Enum.each(fn line ->
    DictionaryLineProcessor.process(line)
  end)
IO.puts "completed seed words"
