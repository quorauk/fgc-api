
defmodule FgcWeb.ScoreboardController do
  use FgcWeb, :controller
  import Ecto.Query

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    scoreboards = Fgc.Repo.all(from s in Fgc.Scoreboards.Scoreboard, where: s.user_id == ^user.id)
    json(conn, scoreboards)
  end

  def create(conn, %{"name" => name, "type" => type}) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, scoreboard} = Fgc.Repo.insert(%Fgc.Scoreboards.Scoreboard{user_id: user.id, name: name, type: type, scoreboard: %{
      round: "",
      player_one: %{tag: "", name: "", score: 0},
      player_two: %{tag: "", name: "", score: 0}
    }})
    json(conn, scoreboard)
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    scoreboard = Fgc.Repo.one(from s in Fgc.Scoreboards.Scoreboard, where: s.id == ^id and s.user_id == ^user.id)
    {:ok, _struct} = Fgc.Repo.delete(scoreboard)
    text(conn, "done")
  end

  def get(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    scoreboard = Fgc.Repo.one(from s in Fgc.Scoreboards.Scoreboard, where: s.id == ^id and s.user_id == ^user.id)
    json(conn, scoreboard)
  end
end
