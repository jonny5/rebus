put("/rebus/words/1", [name: "Tree", pronunciation: "TR IY"])


import Tirexs.Search

defmodule Fart do
  def test do
    if (true), do: (must do: match_phrase "pronunciation", "TR E IY")
    end
  end
end

[
  index: "rebus",
  search: [
    query: [
      bool: [
        must: [
          [ match_phrase: [ pronunciation: "TR E IY"] ]
        ],
        filter: [
          term: [ name: "tree"]
        ]
      ]
    ]
  ]
]
