defmodule Rebus.SubwordGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rebus.SubwordGroup

  schema "subword_groups" do
    field :word_id, :id

    timestamps()
  end

  @doc false
  def changeset(%SubwordGroup{} = subword_group, attrs) do
    subword_group
    |> cast(attrs, [])
    |> validate_required([])
  end
end
