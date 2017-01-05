defmodule Rebus.Repo.Migrations.CreateWord do
  use Ecto.Migration

  def up do
    create table(:words) do
      add :name, :string
      add :pronunciation, :string
      add :pronunciation_length, :integer
      add :has_image, :boolean, default: false, null: false

      timestamps()
    end
    execute "CREATE extension if not exists pg_trgm;"
    execute "CREATE INDEX word_pronunciation_trgm_index ON words USING gin(pronunciation gin_trgm_ops);"

    create index(:words, [:pronunciation_length])
    create index(:words, [:name])
  end

  def down do
    execute "DROP INDEX word_pronunciation_trgm_index;"
    drop index(:words, [:pronunciation_length])
    drop index(:words, [:name])
    drop table(:words)
  end
end
