defmodule Rebus.WordTest do
  use Rebus.ModelCase

  alias Rebus.Word

  @valid_attrs %{has_image: true, name: "some content", pronunciation: "some content", pronunciation_length: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Word.changeset(%Word{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Word.changeset(%Word{}, @invalid_attrs)
    refute changeset.valid?
  end
end
