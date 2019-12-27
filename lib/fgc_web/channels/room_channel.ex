defmodule FgcWeb.RoomChannel do
  use Phoenix.Channel

  def join("scoreboard:" <> scoreboard_id, _params, socket) do
    scoreboard = Fgc.Repo.get!(Fgc.Scoreboards.Scoreboard, scoreboard_id)
    if scoreboard_id == nil do
      {:error, %{reason: "not found"}}
    else
      {:ok , scoreboard.scoreboard, socket}
    end
  end

  def handle_in("scoreboard_update", %{"body" => body}, socket) do
    if socket.assigns[:claims] != nil do
      update_scoreboard(socket.topic, body)
      broadcast socket, "scoreboard_update", %{body: body}
      {:noreply, socket}
    else
      {:stop, "not authenticated", socket} 
    end
  end

  defp update_scoreboard("scoreboard:" <> scoreboard_id, %{"round" => round, "player_one" => p1, "player_two" => p2}) do
    scoreboard = Fgc.Repo.get!(Fgc.Scoreboards.Scoreboard, scoreboard_id)
    body = %{
      :round => round,
      :player_one => p1,
      :player_two => p2
    }
    changeset = scoreboard
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_change(:scoreboard, body)
    Fgc.Repo.update!(changeset)
  end
end