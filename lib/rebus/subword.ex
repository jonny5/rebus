defmodule Rebus.Subword do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rebus.Subword

  schema "subwords" do
    field :position, :integer
    field :word_id, :id
    field :subword_group_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Subword{} = subword, attrs) do
    subword
    |> cast(attrs, [:position])
    |> validate_required([:position])
  end
end
