defmodule Fgc.Repo.Migrations.AddRoleTable do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :guild, :string
      add :role_id, :string

      timestamps()
    end
  end
end
