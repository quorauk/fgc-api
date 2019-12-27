defmodule Fgc.Repo.Migrations.CreateScoreboard do
  use Ecto.Migration

  def change do
    create table(:scoreboards) do
      add :name, :string
      add :type, :string
      add :user_id, references(:users)
      add :scoreboard, :map

      timestamps()
    end
  end
end
