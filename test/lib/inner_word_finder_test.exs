require IEx

defmodule Rebus.InnerWordFinderTest do
  use Rebus.ConnCase

  alias Rebus.{WordNode, InnerWordFinder}

  test "nil with only one word" do
    firefighter = insert(:word, %{name: "firefighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7, has_image: true} )

    node = InnerWordFinder.process(firefighter)
    printed_response = WordNode.print(node)
    assert(printed_response == "")
  end

  test "processes one level deep" do
    firefighter = insert(:word, %{name: "firefighter", pronunciation: "F AY R F AY T ER", pronunciation_length: 7, has_image: true} )
    _fire = insert(:word, %{name: "fire", pronunciation: "F AY R", pronunciation_length: 7, has_image: true} )
    _fighter = insert(:word, %{name: "fighter", pronunciation: "F AY T ER", pronunciation_length: 7, has_image: true} )

    node = InnerWordFinder.process(firefighter)
    printed_response = WordNode.print(node)
    assert(printed_response == "fire + fighter")
  end

  test "processes two levels deep" do
    _high = insert(:word, %{name: "high", pronunciation: "HH AY", pronunciation_length: 2, has_image: true} )
    _way = insert(:word, %{name: "way", pronunciation: "W EY", pronunciation_length: 2, has_image: true} )
    _man = insert(:word, %{name: "man", pronunciation: "M AE N", pronunciation_length: 3, has_image: true} )
    highwayman = insert(:word, %{name: "highwayman", pronunciation: "HH AY W EY M AE N", pronunciation_length: 7, has_image: true} )
    node = InnerWordFinder.process(highwayman)
    printed_response = WordNode.print(node)
    assert(printed_response == "high + way + man")
  end
end
