defmodule Rebus.Repo.Migrations.CreateSubwords do
  use Ecto.Migration

  def change do
    create table(:subwords) do
      add :position, :integer
      add :word_id, references(:words, on_delete: :nothing)
      add :subword_group_id, references(:subword_groups, on_delete: :nothing)

      timestamps()
    end

    create index(:subwords, [:word_id])
    create index(:subwords, [:subword_group_id])
  end
end
