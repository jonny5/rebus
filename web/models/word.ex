defmodule Rebus.Word do
  use Rebus.Web, :model

  schema "words" do
    field :name, :string
    field :pronunciation, :string
    field :pronunciation_length, :integer
    field :has_image, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :pronunciation, :pronunciation_length, :has_image])
    |> validate_required([:name, :pronunciation, :pronunciation_length, :has_image])
  end
end
