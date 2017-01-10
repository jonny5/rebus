import Ecto.Query
alias Rebus.{Word, Repo, WordNode}

word = Rebus.Repo.one(
  from word in Word,
  where: word.name == "giraffe",
  limit: 1
)

Rebus.Finder.process(word) |> Rebus.WordNode.print
