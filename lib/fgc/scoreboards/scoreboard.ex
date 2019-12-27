defmodule Fgc.Scoreboards.Scoreboard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scoreboards" do
    field :name, :string
    field :type, :string
    embeds_one :scoreboard, Fgc.Scoreboards.EmbeddedScoreboard, on_replace: :update
    belongs_to :user, Fgc.UserManager.User
    timestamps()
  end

  def changeset(scoreboard, attrs) do
    scoreboard
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type, :user_id])
  end
end

defmodule Fgc.Scoreboards.EmbeddedScoreboard do
  use Ecto.Schema

  embedded_schema do
    field :round, :string
    field :player_one, :map
    field :player_two, :map
  end

end

defimpl Jason.Encoder, for: Fgc.Scoreboards.EmbeddedScoreboard do
  def encode(value, opts) do
    Jason.Encode.map(Map.take(value, [:round, :player_one, :player_two]), opts)
  end
end

defimpl Jason.Encoder, for: Fgc.Scoreboards.Scoreboard do
  def encode(value, opts) do
    Jason.Encode.map(Map.take(value, [:id, :name, :type]), opts)
  end
end