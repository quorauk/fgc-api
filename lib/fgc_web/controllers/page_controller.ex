defmodule FgcWeb.PageController do
  use FgcWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def protected(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "protected.html", current_user: user)
  end

  def protected_json(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    json(conn, %{user: user.username})
  end
end
