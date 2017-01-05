require IEx

defmodule Rebus.RebusFinderTest do
  use Rebus.ConnCase

  alias Rebus.Word
  alias Rebus.WordNode

  test "prints a list of words" do
    _firefighter = insert(:word, %{name: "firefighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )
    _fire = insert(:word, %{name: "fire", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )
    _fighter = insert(:word, %{name: "fighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )

    list = [%WordNode{name: "fire"}, %WordNode{name: "fighter"}]
    node = %WordNode{name: "firefighter", operator: "+", children: list }
    response = WordNode.print(node)
    assert(response == "(fire + fighter)")
  end

  test "doesn't process partial conjugation matches" do
    insert(:word)
    firefighter = insert(:word, %{name: "firefighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )
    _partial_match = insert(:word, %{name: "fire", pronunciation: "F A", pronunciation_length: 7} )
    node = Rebus.Finder.process(firefighter)
    printed_response = WordNode.print(node)
    assert(printed_response == "(fire + fighter)")
  end

  test "processes a conjugated word" do
    insert(:word)
    firefighter = insert(:word, %{name: "firefighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7} )
    fire = insert(:word, %{name: "fire", pronunciation: "F AY R", pronunciation_length: 7} )
    fighter = insert(:word, %{name: "fighter", pronunciation: "F AY T ER", pronunciation_length: 7} )

    node = Rebus.Finder.process(firefighter)
    printed_response = WordNode.print(node)
    assert(printed_response == "(fire + fighter)")

    response = Rebus.Finder.process(fire)
    assert(WordNode.print(response) == "(firefighter - fighter)")

    response = Rebus.Finder.process(fighter)
    assert(WordNode.print(response) == "(firefighter - fire)")
  end
end
