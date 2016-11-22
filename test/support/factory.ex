defmodule Rebus.Factory do
  use ExMachina.Ecto, repo: Rebus.Repo

  def word_factory do
    %Rebus.Word{
      name: "hello",
      pronunciation: "HH AH L OW",
      pronunciation_length: 4,
      has_image: false,
    }
  end
end
