defmodule Rebus.RebusFinderTest do
  use Rebus.ConnCase

  alias Rebus.Word
  alias Rebus.WordNode

  test "prints a list of words" do
    list = [%WordNode{word: "fire"}, %WordNode{word: "fighter"}]
    node = %WordNode{word: "firefighter", operator: "+", children: list }
    response = WordNode.print(node)
    assert(response == "(fire + fighter)")
  end

  test "processes a conjugated word" do
    insert(:word)
    firefighter = insert(:word, %{name: "firefighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )
    fire = insert(:word, %{name: "fire", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )
    fighter = insert(:word, %{name: "fighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )

    response = Rebus.Finder.process(firefighter)
    assert(WordNode.print(response) == "(fire + fighter)")

    # response = Rebus.Finder.process(fire)
    # assert(WordNode.print(response) == "(firefighter - fighter)")
    #
    # response = Rebus.Finder.process(fighter)
    # assert(WordNode.print(response) == "(firefighter - fire)")
  end
end
