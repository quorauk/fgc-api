defmodule Fgc.Bot.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :guild, :string
    field :role_id, :string

    timestamps()
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:guild, :role_id])
    |> validate_required([:guild, :role_id])
  end
end