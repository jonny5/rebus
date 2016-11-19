defmodule Rebus.Repo.Migrations.CreateWord do
  use Ecto.Migration

  def change do
    create table(:words) do
      add :name, :string
      add :pronunciation, :string
      add :pronunciation_length, :integer
      add :has_image, :boolean, default: false, null: false

      timestamps()
    end

    create index(:words, [:pronunciation_length])
    create index(:words, [:pronunciation])
    create index(:words, [:name])
  end
end
