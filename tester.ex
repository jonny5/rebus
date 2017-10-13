import Ecto.Query
alias Rebus.{Word, Repo, WordNode}

word = Rebus.Repo.one(
  from word in Word,
  where: word.name == "haiti",
  limit: 1
)

Rebus.InnerWordFinder.process("haiti") |> Rebus.WordNode.print
