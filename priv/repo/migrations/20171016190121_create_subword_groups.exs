defmodule Rebus.Repo.Migrations.CreateSubwordGroups do
  use Ecto.Migration

  def change do
    create table(:subword_groups) do
      add :word_id, references(:words, on_delete: :nothing)
      add :remainder, :string
    end

    create index(:subword_groups, [:word_id])
  end
end
