put("/rebus/words/1", [name: "Tree", pronunciation: "TR IY"])


import Tirexs.Search

query = search [index: "rebus"] do
  query do
    bool do
      must do
        match_phrase "pronunciation", "TR IY"
      end
      filter do
        term "name", "tree"
      end
    end
  end
end

Tirexs.Query.create_resource(query)
